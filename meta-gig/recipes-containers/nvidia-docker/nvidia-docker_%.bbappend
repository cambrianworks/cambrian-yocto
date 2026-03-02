SUMMARY = "Support GPU access from docker containers"
DESCRIPTION = "Provides a JSON configuration for allowing nvidia runtime container access to GPU hardware from Docker containers"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = " \
    file://daemon.json \
"

do_install() {
    install -d ${D}${sysconfdir}/docker
    install -m 0755 ${WORKDIR}/daemon.json ${D}${sysconfdir}/docker/daemon.json
}

FILES:${PN} += "${sbindir}/daemon.json"
