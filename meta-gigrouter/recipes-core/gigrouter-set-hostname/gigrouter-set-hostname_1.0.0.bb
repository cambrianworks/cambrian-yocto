SUMMARY = "Set unit hostname automatically"
DESCRIPTION = "Installs a service for a script which automatically sets the unit hostname derived from the SOM's unique serial number"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = " \
    file://gigrouter-set-hostname.sh \
    file://gigrouter-set-hostname.service \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "gigrouter-set-hostname.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/gigrouter-set-hostname.sh ${D}${sbindir}/gigrouter-set-hostname.sh

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/gigrouter-set-hostname.service ${D}${systemd_unitdir}/system/
}

RDEPENDS:${PN} += "bash coreutils"
