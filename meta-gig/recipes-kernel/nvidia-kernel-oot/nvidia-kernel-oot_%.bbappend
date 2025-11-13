FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
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
