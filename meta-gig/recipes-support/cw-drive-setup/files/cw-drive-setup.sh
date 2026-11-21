#!/bin/bash

# Terminate script immediately if a failure is encountered.
# -e: Exit on error.
# -u: Exit if an unitialised variable is used.
# -o pipefail: Exit if any command in a pipeline fails.
set -euo pipefail

###############################################################################
#
# Provisions a secondary NVMe drive as a bootable drive.
#
# Usage:
#    ./cw-drive-setup.sh -d|--drive <drive|auto> -i|--image <image>
#
#        -d|--drive      Target drive to reformat and write, e.g. nvme0n1 or
#                        nvme1n1. "auto" selects the drive by its PCIe
#                        location: the NVMe drive behind a PCIe switch if
#                        there is one (GigRouter), otherwise the only NVMe
#                        drive (GigCompute). Defaults to nvme0n1.
#        -h|--help       Display this usage.
#        -i|--image      Image to write to rootfs partition. Defaults to system.img.
#
###############################################################################

# Execution steps
readonly do_stop_k3s=y
readonly do_unmount_drive=y
readonly do_wipe_drive=y
readonly do_partition_drive=y
readonly do_write_image=y
readonly do_update_extlinux_conf=y

###############################################################################
# Data
###############################################################################

readonly partition_table="Label,Start,End,Format,Duplicate
APP,1561624576B,31089524735B,ext4,n
APP_b,31089524736B,60617424895B,ext4,n
A_kernel,20480B,134238207B,,y
A_kernel-dtb,134238208B,135024639B,,y
A_reserved_on_user,135024640B,168185855B,,y
B_kernel,168185856B,302403583B,,y
B_kernel-dtb,302403584B,303190015B,,y
B_reserved_on_user,303190016B,336351231B,,y
recovery,336351232B,420237311B,,y
recovery-dtb,420237312B,420761599B,,y
esp,420761600B,487870463B,fat32,y
recovery_alt,487870464B,571756543B,,y
recovery-dtb_alt,571756544B,572280831B,,y
esp_alt,572280832B,639389695B,,y
UDA,639401984B,1058832383B,,y
reserved,1058832384B,1561624575B,,n"

###############################################################################
# Utility functions
###############################################################################

create_esp_partition() {
    # The EFI System Parition is a special case which adheres to
    # a general UEFI specification, rather than anything nvidia specific.
    # It requires a fat32 filesystem, since that can be implemented in
    # smaller targets without complicated drivers, and the boot and
    # esp flags set.
    parted /dev/$1 --script mkpart primary fat32 $3 $4 && partprobe /dev/$1 && udevadm settle && udevadm settle
    partition_number=$(lsblk -n /dev/$1 | grep "part" | wc -l)
    if ! mkfs.vfat -F 32 -n $2 /dev/$1p$partition_number; then
        msg "Failed to create esp partition"
        exit 1
    fi
    parted /dev/$1 --script name $partition_number $2 && partprobe /dev/$1 && udevadm settle
    parted /dev/$1 --script set $partition_number boot on && partprobe /dev/$1 && udevadm settle
    parted /dev/$1 --script set $partition_number esp on && partprobe /dev/$1 && udevadm settle

    # Copy the EFI boot binary from the emmc esp partition
    # to the NVME's equivalent.
    esp_source_partition=$(parted -m /dev/mmcblk0 -m print | grep ":esp:" | cut -d: -f1)
    esp_destination_partition=$(parted -m /dev/$1 -m print | grep ":esp:" | cut -d: -f1)
    if [[ ! -d /tmp/esp-src ]]; then
        mkdir /tmp/esp-src
    fi
    mount -t vfat /dev/mmcblk0p$esp_source_partition /tmp/esp-src
    if [[ ! -d /tmp/esp-dest ]]; then
        mkdir /tmp/esp-dest
    fi
    mount -t vfat /dev/$1p$esp_destination_partition /tmp/esp-dest
    cp -r /tmp/esp-src/* /tmp/esp-dest/
    umount /tmp/esp-src
    rm -r /tmp/esp-src
    umount /tmp/esp-dest
    rm -r /tmp/esp-dest
}

create_partition() {
    parted /dev/$1 --script mkpart primary $5 $3 $4 && partprobe /dev/$1 && udevadm settle
    partition_number=$(lsblk -n /dev/$1 | grep "part" | wc -l)
    parted /dev/$1 --script name $partition_number $2 && partprobe /dev/$1 && udevadm settle
    mkfs.$5 /dev/$1p$partition_number
    parted /dev/$1 --script set $partition_number msftdata on && partprobe /dev/$1 && udevadm settle
}

create_partition_table() {
    parted /dev/$1 --script mklabel gpt && partprobe /dev/$1 && udevadm settle
}

create_raw_partition() {
    # When creating a bootable Jetson drive, nvidia doesn't use paritions with
    # standard file systems (with some exceptions such as rootfs and efi, where
    # other standards compel them). Instead, partitions are defined to reserve
    # space but data is written directly as raw binary data (e.g., kernels,
    # DTBs etc).

    # Create a partition in non-interactive mode. Parameters are:
    # parted /dev/<device> --script mkpart "<partition label>" <start point> <end point>
    parted /dev/$1 --script mkpart "${2}" $3 $4 && partprobe /dev/$1 && udevadm settle
    partition_number=$(lsblk -n /dev/$1 | grep "part" | wc -l)
    parted /dev/$1 --script set $partition_number msftdata on && partprobe /dev/$1 && udevadm settle
}

describe_drive() {
    # Model and serial number, e.g. "Samsung SSD 980 PRO 2TB S6B0NU0W519862H"
    local model="" serial=""
    read -r model 2>/dev/null <"/sys/block/$1/device/model" || true
    read -r serial 2>/dev/null <"/sys/block/$1/device/serial" || true
    echo "$model $serial"
}

duplicate_partition() {
    msg "Duplicating partition: $2"
    source_partition=$(parted -m /dev/mmcblk0 -m print | grep ":$2:" | cut -d: -f1)
    dest_partition=$(parted -m /dev/$1 -m print | grep ":$2:" | cut -d: -f1)

    if [[ -z "$source_partition" ]]; then
        msg "Partition $2 not found on source device: mmcblk0"
        exit 1
    fi
    if [[ -z "$dest_partition" ]]; then
        msg "Partition $2 not found on destination device: $1"
        exit 1
    fi
    dd if=/dev/mmcblk0p$source_partition of=/dev/$1p$dest_partition bs=1M conv=fsync
}

list_nvme_drives() {
    local dev name
    for dev in /sys/block/nvme*; do
        name=${dev##*/}
        if [[ $name =~ ^nvme[0-9]+n[0-9]+$ ]]; then
            echo "$name"
        fi
    done
}

msg() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)]: $@" >&2
}

nvme_pci_depth() {
    # Number of PCI functions from the root port down to the drive. A drive
    # wired straight to a Tegra root port has 2 (root port, drive); one on
    # the far side of a PCIe switch has 4 (root port, switch upstream port,
    # switch downstream port, drive)
    local component depth=0
    local -a components
    IFS=/ read -ra components <<<"$(nvme_pci_function "$1")"
    for component in "${components[@]}"; do
        if [[ $component =~ ^[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\.[0-7]$ ]]; then
            depth=$((depth + 1))
        fi
    done
    echo "$depth"
}

nvme_pci_function() {
    readlink -f "/sys/block/$1/device/device" 2>/dev/null || true
}

substitute_extlinux_conf() {
    app_partition=$(parted -m /dev/$1 -m print | grep ":$2:" | cut -d: -f1)
    app_device=/dev/$1p$app_partition

    # NVMe names (nvme0n1, nvme1n1, ...) follow driver probe order, which is
    # may not be  stable across boots when more than one NVMe drive is present
    # so refer to the rootfs by its GPT partition UUID instead
    if [[ "$1" == mmcblk* ]]; then
        root_spec=$app_device
    else
        part_uuid=$(lsblk -dno PARTUUID "$app_device")
        if [[ -z "$part_uuid" ]]; then
            msg "Error: unable to read PARTUUID of $app_device"
            exit 1
        fi
        root_spec="PARTUUID=$part_uuid"
    fi

    msg "Updating extlinux.conf on partition $2 of $1: root=$root_spec"
    if [[ ! -d /tmp/app ]]; then
        mkdir /tmp/app
    fi
    mount $app_device /tmp/app
    sed -i "s#\([[:space:]]\)root=[^[:space:]]*#\1root=$root_spec#g" /tmp/app/boot/extlinux/extlinux.conf
    umount /tmp/app
    rm -r /tmp/app
}

usage() {
    msg "Usage:
    ./cw-drive-setup.sh -d|--drive <drive|auto> -i|--image <image>

        -d|--drive      Target drive to reformat and write, e.g. nvme0n1 or
                        nvme1n1. \"auto\" selects the drive by its PCIe
                        location: the NVMe drive behind a PCIe switch if
                        there is one (GigRouter), otherwise the only NVMe
                        drive (GigCompute). Defaults to nvme0n1.
        -h|--help       Display this usage.
        -i|--image      Image to write to rootfs partition. Defaults to system.img."
}

###############################################################################
# Execution functions
###############################################################################

partition_drive() {
    msg "Partitioning drive: $1"
    create_partition_table $1

    echo "$partition_table" | while IFS=',' read -r label start end format duplicate; do
        [[ "$label" == "Label" ]] && continue
        msg "Creating: $label $start $end $format"

        # The esp partition is a special case
        if [[ "$label" == "esp" ]]; then
            create_esp_partition $1 $label $start $end
        elif [[ -z "$format" ]]; then
            create_raw_partition $1 $label $start $end
        else
            create_partition $1 $label $start $end $format
        fi
        if [[ "$duplicate" == "y" ]]; then
            duplicate_partition $1 $label
        fi
    done
}

resolve_auto_drive() {
    # Choose the drive by its location on the PCIe bus, not by name: nvme0 and
    # nvme1 follow driver probe order. Hardware configurations:
    #   1) A GigRouter's rootfs drives is behind the PCIe switch (the
    #   other drive is on a root port).
    #   2) A GigCompute has a single drive.
    local d depth pci location
    local -a drives=() candidates=()
    mapfile -t drives < <(list_nvme_drives)

    msg "NVMe drives found: ${#drives[@]}"
    for d in "${drives[@]}"; do
        depth=$(nvme_pci_depth "$d")
        pci=$(nvme_pci_function "$d")
        case $depth in
        0) location="unknown PCIe path" ;;
        1 | 2) location="on root port" ;;
        *)
            location="behind PCIe switch"
            candidates+=("$d")
            ;;
        esac
        msg "  $d  ${pci##*/}  $location  $(describe_drive "$d")"
    done

    if [[ ${#drives[@]} -eq 0 ]]; then
        msg "Error: no NVMe drive found"
        exit 1
    fi

    # No drive behind a switch: use the only drive present.
    if [[ ${#candidates[@]} -eq 0 ]]; then
        candidates=("${drives[@]}")
    fi

    if [[ ${#candidates[@]} -ne 1 ]]; then
        msg "Error: can't choose a drive automatically: expected one NVMe drive behind a PCIe switch, or a single NVMe drive. Specify the drive with -d."
        exit 1
    fi

    msg "Auto-selected drive: ${candidates[0]}"
    echo "${candidates[0]}"
}

stop_k3s() {
    if systemctl is-active k3s; then
        msg "k3s is running, stopping"
        systemctl stop k3s
    fi
}

unmount_drive() {
    if findmnt --source /dev/$1 >/dev/null; then
        umount -lf /dev/${1}p*
    fi
}

update_extlinux_conf() {
    substitute_extlinux_conf $1 "APP"
    substitute_extlinux_conf $1 "APP_b"
}

validate_drive() {
    if [[ ! $1 =~ ^nvme[0-9]+n[0-9]+$ || ! -e /sys/block/$1 ]]; then
        msg "Error: '$1' is not an NVMe drive on this system. Found: $(list_nvme_drives | tr '\n' ' ')(or use -d auto)"
        exit 1
    fi
}

wipe_drive() {
    msg "Wiping content of drive $1"
    if ! wipefs --all --force /dev/$1; then
        msg "Error: Wiping target drive failed: $1"
        exit 1
    fi
}

write_image() {
    msg "Writing $2 to partition /dev/$1p$3"
    simg2img $2 /dev/$1p$3
    e2fsck -f /dev/$1p$3
    resize2fs /dev/$1p$3
}

###############################################################################
# Execute script
###############################################################################

drive=nvme0n1
image=system.img

while [[ $# -gt 0 ]]; do
    case $1 in
    -d | --drive)
        drive="${2:-}"
        shift $(($# > 1 ? 2 : 1))
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    -i | --image)
        image="${2:-}"
        shift $(($# > 1 ? 2 : 1))
        ;;
    *)
        shift 1
        ;;
    esac
done

if [[ "$drive" == "auto" ]]; then
    drive=$(resolve_auto_drive)
else
    validate_drive "$drive"
fi

root_device=$(findmnt -nvo SOURCE /)
if [[ "$root_device" == *"$drive"* ]]; then
    msg "Error: cannot provision a drive hosting the currently mounted rootfs: $root_device"
    exit 1
fi

msg "Setting up drive: $drive ($(describe_drive "$drive")), using image: $image"
read -p "Press ENTER to continue (c to cancel) ... " entry
if [ ! -z $entry ]; then
    if [ $entry = "c" ]; then
        msg "Setup cancelled"
        exit 0
    fi
fi

# If partitioning happens but then fail to write a rootfs
# the unit will need recovery to restore proper booting
# as the presence of a second APP partition will confuse
# the init script. If it doesn't contain a valid rootfs
# the system will be unable boot and require recovery.
# Best to address this upfront _before_ partitions
# are defined.
if [[ ! -f $image ]]; then
    msg "Error: image file not found"
    exit 1
fi

if [ $do_stop_k3s = "y" ]; then
    stop_k3s
fi

if [ $do_unmount_drive = "y" ]; then
    unmount_drive $drive
fi

if [ $do_wipe_drive = "y" ]; then
    wipe_drive $drive
fi

if [ $do_partition_drive = "y" ]; then
    partition_drive $drive
fi

if [ $do_write_image = "y" ]; then
    # Write to APP. APP is always p1
    write_image $drive $image "1"
    # Write to APP_b. APP_b is always p2
    write_image $drive $image "2"
fi

if [ $do_update_extlinux_conf = "y" ]; then
    # Ensure that the B partition of the eMMC drive, which
    # was booted to run this script, isn't overlooked and
    # is also bootable.
    update_extlinux_conf "mmcblk0"
    update_extlinux_conf $drive
fi

msg "Setup completed"
exit 0

##############################################################################
# End execution
##############################################################################
