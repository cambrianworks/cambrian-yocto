DESCRIPTION = "Virtual/dtb provider for Gig product device trees"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "^(gigrouter|gigcompute)$"

INHIBIT_DEFAULT_DEPS = "1"
DEPENDS += "nvidia-kernel-oot"

inherit deploy kernel-arch devicetree

PROVIDES = "virtual/dtb"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add your DTB files to the SRC_URI
SRC_URI += " \
    file://tegra234-p3701-0008-gr002007.dts \
"

PLATFORM_DTB_FILE = "tegra234-p3701-0008-gr002007"

do_compile() {
    dtc -I dts -o dtb -o ${WORKDIR}/${PLATFORM_DTB_FILE}.dtb ${WORKDIR}/${PLATFORM_DTB_FILE}.dts
    if [ ! -e ${WORKDIR}/${PLATFORM_DTB_FILE}.dtb ]; then
        bbfatal "Failed to compile DTB file: ${PLATFORM_DTB_FILE}"
    fi
}

do_deploy() {
    install -d ${DEPLOYDIR}/devicetree
    install -m 0644 ${STAGING_DIR_HOST}/boot/devicetree/* ${DEPLOYDIR}/devicetree/

    # Adding GigRouter DTBs
    install -m 0644 ${WORKDIR}/${PLATFORM_DTB_FILE}.dtb ${DEPLOYDIR}/
    install -m 0644 ${WORKDIR}/${PLATFORM_DTB_FILE}.dtb ${DEPLOYDIR}/devicetree/
}

addtask compile before do_deploy after do_fetch
addtask deploy before do_build after do_compile

ALLOW_EMPTY:${PN} = "1"
