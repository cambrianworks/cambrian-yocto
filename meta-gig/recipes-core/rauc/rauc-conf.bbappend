FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Keys are decrypted prior to the build being initiated
# so this directory is presumed to exist. These recipes
# are only included on build targets which support using
# the update keys.
FILESEXTRAPATHS:prepend := "${TOPDIR}/../keys:"

SRC_URI += " \
    file://jetson-boot-backend \
    file://rauc.conf \
    file://system.conf \
    file://cambrian-works.cert.pem \
"
RDEPENDS:${PN} += "bash coreutils"

do_install:append() {

    # Delete the default example system.conf supplied
    # by the rauc-conf recipe.
    rm -f ${D}${sysconfdir}/rauc/system.conf

    # Install the rauc parition configuration and update keys
    # specific to Cambrian Works targets
    install -d ${D}${sysconfdir}/rauc
    install -m 0644 ${WORKDIR}/system.conf ${D}${sysconfdir}/rauc/system.conf
    install -m 0644 ${WORKDIR}/cambrian-works.cert.pem ${D}${sysconfdir}/rauc/cambrian-works.cert.pem

    # Apply the script which bridges rauc verbs to
    # the UEFI state exposed by nvidia's nvbootctl
    # tooling.
    install -d ${D}${libdir}/rauc/backend
    install -m 0755 ${WORKDIR}/jetson-boot-backend ${D}${libdir}/rauc/backend/jetson-boot-backend

    # Include setup for the service at runtime
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/rauc.conf ${D}${sysconfdir}/tmpfiles.d/rauc.conf
}

FILES:${PN} += "${sysconfdir}/rauc/system.conf"
FILES:${PN} += "${sysconfdir}/rauc/cambrian-works.cert.pem"
FILES:${PN} += "${sysconfdir}/tmpfiles.d/rauc.conf"
FILES:${PN} += "${libdir}/rauc/backend/jetson-boot-backend"

