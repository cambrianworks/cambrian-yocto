SUMMARY = "Dummy - provide the apt-utils package to satisfy dependencies."
DESCRIPTION = "This recipe creates a dummy package to maintain compatibility with software that expects apt-utils even where it's not really required."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://apt-utils.txt \
"

do_install() {
    install -d ${D}/opt/dummy
    install -m 0755 ${WORKDIR}/apt-utils.txt ${D}/opt/dummy/apt-utils.txt
}
FILES:${PN} += "/opt/dummy/apt-utils.txt"
