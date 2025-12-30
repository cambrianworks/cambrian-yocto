FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# N.B., 0001-pcie-msi-distribution-devicetree.patch
# In between R35 and R36 there's a regession in the way PCIe MSI
# interrupts are handled, causing them to be handled exclusively
# by CPU0 resulting in highly reduced performance of the
# GigRouter/GigCompute's 10G ports. The detailed patch file addresses
# the issue so that they can operate unimpeded.
#
# For more information:
#
# https://forums.developer.nvidia.com/t/r36-3-patch-to-re-enable-gicv2m-for-pcie-msi-interrupts-and-restore-i-o-performance/297495
#
# See also: meta-gig/recipes-kernel/linux

SRC_URI += " \
    file://0001-pcie-msi-distribution-devicetree.patch \
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
