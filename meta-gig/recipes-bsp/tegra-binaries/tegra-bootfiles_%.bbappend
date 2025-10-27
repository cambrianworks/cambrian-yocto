FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI:append:gig = " \
    file://tegra234-gigrouter-mb1-bct-gpio-p3701-0000.dtsi \
    file://tegra234-gigrouter-mb1-bct-gpio-p3701-0000-a04.dtsi \
    file://tegra234-gigrouter-mb1-bct-pinmux-p3701-0000.dtsi \
    file://tegra234-gigrouter-mb1-bct-pinmux-p3701-0000-a04.dtsi \
"

# Hack: As the fetch task is disabled for this recipe, we have to directly access the files."
CUSTOM_DTSI_DIR := "${THISDIR}/${BPN}"
do_install:append:gig() {
    install -m 0644 ${CUSTOM_DTSI_DIR}/tegra234-gigrouter-mb1-bct-gpio-p3701-0000.dtsi  ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/tegra234-gigrouter-mb1-bct-gpio-p3701-0000-a04.dtsi  ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/tegra234-gigrouter-mb1-bct-pinmux-p3701-0000.dtsi  ${D}${datadir}/tegraflash/
    install -m 0644 ${CUSTOM_DTSI_DIR}/tegra234-gigrouter-mb1-bct-pinmux-p3701-0000-a04.dtsi ${D}${datadir}/tegraflash/
}
