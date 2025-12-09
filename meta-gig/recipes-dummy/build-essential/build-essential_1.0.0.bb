SUMMARY = "Dummy - provide the build-essential package to satisfy dependencies."
DESCRIPTION = "This recipe creates a dummy package to maintain compatibility with software that expects build-essential even where it's not really required."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://build-essential.txt \
"

do_install() {
    install -d ${D}/opt/dummy
    install -m 0755 ${WORKDIR}/build-essential.txt ${D}/opt/dummy/build-essential.txt
}
FILES:${PN} += "/opt/dummy/build-essential.txt"
