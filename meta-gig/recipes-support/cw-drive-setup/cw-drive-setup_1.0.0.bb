SUMMARY = "Provision a secondary drive as a bootable device."
DESCRIPTION = "Installs a script which installs bootloader and rootfs onto a designated drive."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = " \
    file://cw-drive-setup.sh \
"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/cw-drive-setup.sh ${D}${sbindir}/cw-drive-setup.sh
}

FILES:${PN} += "${sbindir}/cw-drive-setup.sh"

RDEPENDS:${PN} += "bash coreutils"
