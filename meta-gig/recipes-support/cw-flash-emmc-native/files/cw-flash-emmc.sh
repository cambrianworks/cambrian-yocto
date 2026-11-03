#!/bin/bash

###############################################################################
#
# Usage:
# sudo ./cw-flash-emmc.sh (optional)-n|--no-flash
#
#   -n | --no-flash Creates an ext4.img file of the rootfs (cambrian-image.ext4.img)
#                   which can be used with cw-drive-setup.sh but doesn't flash
#                   the system.
#
# Writes the image directly to eMMC while the target system is in recovery
# mode.
#
###############################################################################

# Execution steps
readonly do_generate_image=y
do_flash_image=y

# Variables
ROOTFS_IMAGE="cambrian-image.ext4"

msg() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)]: $@" >&2
}

usage() {
    msg "
    Usage:
    sudo ./cw-flash-emmc.sh (optional)-n|--no-flash

        -n | --no-flash Creates an ext4.img file of the rootfs (cambrian-image.ext4.img)
                        which can be used with cw-drive-setup.sh but doesn't flash
                        the system."
}

flash_image() {
    dataargs=()
    if [ -n "$DATAFILE" ] && [ -e "$DATAFILE" ]; then
        dataargs=(--datafile "$DATAFILE")
    fi

    exec ./"${FLASH_HELPER:-tegra-flash-helper.sh}" "${dataargs[@]}" \
        flash.xml.in "$LNXFILE" "$image" "$@"
}

generate_image() {
    image="${ROOTFS_IMAGE}.img"
    msg "Generating ${image}"
    if [ ! "$image" -nt "$ROOTFS_IMAGE" ]; then
        msg "Creating image $image..."
        rm -f "$image.tmp"
        ./mksparse -b "${BLOCKSIZE:-4096}" --fillpattern=0 "$ROOTFS_IMAGE" "$image.tmp"
        mv "$image.tmp" "$image"
    fi
}

###############################################################################
# Execute script
###############################################################################

if [ ! -e .env.initrd-flash ]; then
    msg "ERR: .env.initrd-flash not found; run this from an extracted tegraflash package" >&2
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
    -n | --no-flash)
        do_flash_image=n
        shift 1
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        shift 1
        ;;
    esac
done

# Source information about the target from a hidden
# file generated and bundled by the build process
declare -A DEFAULTS
. ./.env.initrd-flash

# Validate variables that are expected to be supplied by
# # the build process
: "${MACHINE:?not set in .env.initrd-flash}"
: "${LNXFILE:?not set in .env.initrd-flash}"
: "${ROOTFS_IMAGE:?not set in .env.initrd-flash}"
export MACHINE

if [ "$do_generate_image" == "y" ]; then
    generate_image
    msg "Image generated"
fi

if [ "$do_flash_image" == "y" ]; then
    flash_image
    msg "Flashing complete"
fi

exit 0

###############################################################################
# End execution
###############################################################################
