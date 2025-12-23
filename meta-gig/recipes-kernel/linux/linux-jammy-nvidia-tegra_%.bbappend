# In between R35 and R36 there's a regession in the way PCIe MSI
# interrupts are handled, causing them to be handled exclusively
# by CPU0 resulting in highly reduced performance of the
# GigRouter/GigCompute's 10G ports. The detailed patch file addresses
# the issue so that they can operate unimpeded.
#
# For more information:
#
# https://forums.developer.nvidia.com/t/r36-3-patch-to-re-enable-gicv2m-for-pcie-msi-interrupts-and-restore-i-o-performance/297495
#
# See also: meta-gig/recipes-kernel/nvidia-kernel-oot

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://0001-pcie-msi-distribution-kernel.patch \
"

