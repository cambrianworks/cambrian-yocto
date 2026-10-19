FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Patch files and their functions are:
#
# 0001-pcie-msi-distribution.patch
# The kernel is grouping PCIe interrupts onto a single CPU
# core, causing the interface to run slowly. This patch allows
# them to be distributed across multiple cores. The patch will
# be deprecated when moving to wrynose which has a cleaner
# mechanism for achieving the same goal.
#
# For more information:
#
# https://forums.developer.nvidia.com/t/r36-3-patch-to-re-enable-gicv2m-for-pcie-msi-interrupts-and-restore-i-o-performance/297495
#
# See also: meta-gig/recipes-kernel/linux
#
# 0002-USB-peripheral-mode.patch
# The flashing USB port wired as a host port (i.e., VBUS is
# connected directly to a regulator as an output for peripherals).
# However, it's neccessary to use this port as a peripheral port
# when flashing images to eMMC or SSD using initrd-flash. This patch
# concocts a fake regulator input for the driver so it identifies
# the port as a peripheral, alllowing it to be used for flashing.
#
# 0003-remove-camera-module.patch
# tegra234-p3737-0000+p3701-0000-dynamic.dtbo incorporates device
# tree attributes for including camera hardware which isn't present
# on the GC/GR. Unfortunately, the impact is not benign and some of
# the camera related nodes will do things like hog GPIO ports which
# we use for other things. This patch removes camera related
# configuration from that DTBO altogether.
#
# 0004-enable-uarts.patch
# Enable UART 2 in PIO (programmable I/O) mode.
SRC_URI += " \
    file://0001-pcie-msi-distribution.patch \
    file://0002-USB-peripheral-mode.patch \
    file://0003-remove-camera-module.patch \
    file://0004-enable-uarts.patch \
    file://tegra234-p3701-0008-gr002007.dts \
"

DEPENDS += "dtc-native"

inherit deploy

do_compile:append() {
    ${CPP} -nostdinc \
        -I${STAGING_KERNEL_DIR}/include \
        -I${STAGING_KERNEL_DIR}/arch/arm64/boot/dts \
        -undef -x assembler-with-cpp \
        ${WORKDIR}/tegra234-p3701-0008-gr002007.dts | \
    dtc -@ -I dts -O dtb -o ${WORKDIR}/tegra234-p3701-0008-gr002007.dtbo -
}

do_install:append() {
    install -d ${D}/boot/devicetree
    install -m 0644 ${WORKDIR}/tegra234-p3701-0008-gr002007.dtbo ${D}/boot/devicetree/
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/tegra234-p3701-0008-gr002007.dtbo ${DEPLOYDIR}/
}

addtask deploy after do_install before do_build

FILES:${PN} += "/boot/devicetree/tegra234-p3701-0008-gr002007.dtbo"
