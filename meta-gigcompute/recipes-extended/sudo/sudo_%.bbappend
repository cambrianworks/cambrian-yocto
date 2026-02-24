FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://gigcompute-sudo \
"

do_install:append() {
    install -d ${D}${sysconfdir}/sudoers.d
    install -m 0440 ${WORKDIR}/gigcompute-sudo ${D}${sysconfdir}/sudoers.d/gigcompute-sudo
}

FILES:${PN} += "${sysconfdir}/sudoers.d"
