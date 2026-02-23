SUMMARY = "Provide access to the GPIO devices for the gpio group"
DESCRIPTION = "Installs a udev rule which adds enumerated GPIO device nodes to the gpio group automatically."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = " \
    file://99-gpio.rules \
"

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r gpio"

do_install() {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/99-gpio.rules ${D}${sysconfdir}/udev/rules.d/
}

FILES:${PN} += "${sysconfdir}/udev/rules.d/99-gpio.rules"
