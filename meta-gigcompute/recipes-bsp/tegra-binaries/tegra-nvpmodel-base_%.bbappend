FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://nvpmodel_p3701_gigcompute.conf \
"

do_install:append() {
    install -m 0440 ${WORKDIR}/nvpmodel_p3701_gigcompute.conf ${D}${sysconfdir}/nvpmodel.conf
}

FILES:${PN} += "${sysconfdir}/nvpmodel.conf"
