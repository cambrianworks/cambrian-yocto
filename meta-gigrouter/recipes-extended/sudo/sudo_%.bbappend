FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://gigrouter-sudo \
"

do_install:append() {
    install -d ${D}${sysconfdir}/sudoers.d
    install -m 0440 ${WORKDIR}/gigrouter-sudo ${D}${sysconfdir}/sudoers.d/gigrouter-sudo
}

FILES:${PN} += "${sysconfdir}/sudoers.d"
