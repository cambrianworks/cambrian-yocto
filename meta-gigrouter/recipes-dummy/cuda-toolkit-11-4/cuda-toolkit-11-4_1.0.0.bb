SUMMARY = "Dummy - provide the cuda-toolkit-11-4 package to satisfy dependencies."
DESCRIPTION = "This recipe creates a dummy package to maintain compatibility with software that expects cuda-toolkit-11-4 even where it's not really required."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://cuda-toolkit-11-4.txt \
"

do_install() {
    install -d ${D}/opt/dummy
    install -m 0755 ${WORKDIR}/cuda-toolkit-11-4.txt ${D}/opt/dummy/cuda-toolkit-11-4.txt
}
FILES:${PN} += "/opt/dummy/cuda-toolkit-11-4.txt"
