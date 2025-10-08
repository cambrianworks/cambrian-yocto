do_install:append() {
    install -d ${D}${datadir}/keyrings
}

FILES:${PN} += "${datadir}/keyrings"
