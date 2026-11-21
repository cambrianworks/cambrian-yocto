FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://0001-assoc_array.patch \
    file://0002-keyring.patch \
    file://0003-gic-msi-distribution.patch \
    file://custom-options.cfg \
"

