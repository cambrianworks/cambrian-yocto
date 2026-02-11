SUMMARY = "Provide an interactive console on the secondary serial device."
DESCRIPTION = "When a touch file is present will start an interactive console on the secondary serial device."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = " \
    file://condition.conf \
"

TOUCH_FILE = "/etc/cw-interactive-ttyTHS1"

inherit allarch

do_install() {
    install -d ${D}${sysconfdir}/systemd/system/getty.target.wants
    install -d ${D}${sysconfdir}/systemd/system/serial-getty@ttyTHS1.service.d

    # Use the existing serial-getty system file with an argument for ttyTHS1
    ln -sf ${libdir}/systemd/system/serial-getty@.service \
        ${D}${sysconfdir}/systemd/system/getty.target.wants/serial-getty@ttyTHS1.service

    # Inhibit starting the service unless a touch file has been added
    # so that the support is optional to the end user
    if [ -f "${WORKDIR}/condition.conf" ]; then
        sed "s|@TOUCH_FILE@|${TOUCH_FILE}|g" ${WORKDIR}/condition.conf \
            > ${D}${sysconfdir}/systemd/system/serial-getty@ttyTHS1.service.d/condition.conf
    fi
}

FILES:${PN} += "${sysconfdir}/systemd/system/"
