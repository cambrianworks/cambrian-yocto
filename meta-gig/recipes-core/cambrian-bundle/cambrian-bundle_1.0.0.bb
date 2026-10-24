SUMMARY = "Construct flashable raucb bundle"
DESCRIPTION = "Cambrian bundle"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "jetson-agx-orin"
RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_SLOTS = "rootfs"

RAUC_SLOT_rootfs = "cambrian-image"
RAUC_SLOT_rootfs[fstype] = "ext4"
RAUC_SLOT_rootfs[file] = "cambrian-image-${MACHINE}.rootfs.ext4"

RAUC_KEYRING_FILE = "${TOPDIR}/../keys/cambrian-works.cert.pem"
RAUC_KEY_FILE = "${TOPDIR}/../keys/private/cambrian-works.key.pem"
RAUC_CERT_FILE = "${TOPDIR}/../keys/cambrian-works.cert.pem"
