FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://gigcompute-sudo \
    file://sudo \
"

do_install:append() {
    install -d ${D}${sysconfdir}/sudoers.d
    install -m 0440 ${WORKDIR}/gigcompute-sudo ${D}${sysconfdir}/sudoers.d/gigcompute-sudo

    install -d ${D}${datadir}/bash-completion/completions
    install -m 0644 ${WORKDIR}/sudo ${D}${datadir}/bash-completion/completions/sudo
}

FILES:${PN} += "${sysconfdir}/sudoers.d"
FILES:${PN} += "${datadir}/bash-completion/completions/sudo"
