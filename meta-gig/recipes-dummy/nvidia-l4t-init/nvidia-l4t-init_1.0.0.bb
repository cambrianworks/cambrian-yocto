SUMMARY = "Dummy - provide the nvidia-l4t-init package to satisfy dependencies."
DESCRIPTION = "This recipe creates a dummy package to maintain compatibility with software that expects nvidia-l4t-init even where it's not really required."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://nvidia-l4t-init.txt \
"

do_install() {
    install -d ${D}/opt/dummy
    install -m 0755 ${WORKDIR}/nvidia-l4t-init.txt ${D}/opt/dummy/nvidia-l4t-init.txt
}
FILES:${PN} += "/opt/dummy/nvidia-l4t-init.txt"
