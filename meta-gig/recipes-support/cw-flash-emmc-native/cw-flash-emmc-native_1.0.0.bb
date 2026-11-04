SUMMARY = "Provide a script for flashing image to eMMC"
DESCRIPTION = "Inserts a script into the tegraflash bundle which can flash directly to eMMC while in recovery mode."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += "file://cw-flash-emmc.sh"
S = "${UNPACKDIR}"

inherit native
do_install:append() {
    install -d ${D}${bindir}/tegra-flash
    install -m 0755 ${S}/cw-flash-emmc.sh ${D}${bindir}/tegra-flash/
}
