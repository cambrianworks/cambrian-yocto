FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://lxgbe-driver-fragment.cfg \
"
KERNEL_CONFIG_FRAGMENTS += "${WORKDIR}/lxgbe-driver-fragment.cfg"
