DESCRIPTION = "Virtual/dtb provider for GigRouter device trees"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "gigrouter"

INHIBIT_DEFAULT_DEPS = "1"
DEPENDS += "nvidia-kernel-oot"

inherit deploy kernel-arch devicetree

PROVIDES = "virtual/dtb"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add your DTB files to the SRC_URI
SRC_URI += " \
    file://tegra234-gigrouter-p3737-0000+p3701-0000.dtb \
    file://tegra234-gigrouter-p3737-0000+p3701-0004.dtb \
    file://tegra234-gigrouter-p3737-0000+p3701-0005.dtb \
    file://tegra234-gigrouter-p3737-0000+p3701-0008.dtb \
"

do_deploy() {
    for dtb in ${KERNEL_DEVICETREE}; do
        dtbf="${STAGING_DIR_HOST}/boot/devicetree/$dtb"
        if [ ! -f "$dtbf" ]; then
            bbfatal "Not found: $dtbf"
        fi
    done
    install -d ${DEPLOYDIR}/devicetree
    install -m 0644 ${STAGING_DIR_HOST}/boot/devicetree/* ${DEPLOYDIR}/devicetree/

    # Adding GigRouter DTBs
    install -m 0644 ${WORKDIR}/tegra234-gigrouter-p3737-0000+p3701-0000.dtb ${DEPLOYDIR}/devicetree/
    install -m 0644 ${WORKDIR}/tegra234-gigrouter-p3737-0000+p3701-0004.dtb ${DEPLOYDIR}/devicetree/
    install -m 0644 ${WORKDIR}/tegra234-gigrouter-p3737-0000+p3701-0005.dtb ${DEPLOYDIR}/devicetree/
    install -m 0644 ${WORKDIR}/tegra234-gigrouter-p3737-0000+p3701-0008.dtb ${DEPLOYDIR}/devicetree/
}

addtask deploy before do_build after do_install

ALLOW_EMPTY:${PN} = "1"
