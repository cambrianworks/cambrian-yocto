SUMMARY = "Create the default gigcompute user"
DESCRIPTION = "This recipe creates a default user, named gigcompute, on the target system"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SECTION = "Custom"
PR = "r0"
RDEPENDS:${PN} += " bash"

inherit useradd

USERADD_PACKAGES = "${PN}"

# Provide a profile.d script which adds /usr/sbin to
# user's PATH so that they can access utilities for
# interfacing with system hardware
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://system-binaries.sh \
"

# SHA-512 hash of the gigcompute password
PASSWORD = "\$6\$d38sBmIFPhm7CsnM\$KCi/5N62VQMo7u8yxV5ZY3xBFGz7aOrd0lvv2GMnVUnBEBxyCv0d3UjP24GSgIoJ6EbN5zt9l05Yr14j3Ytxh0"

# netdev allows the user to configure NIC devices. i2c allows for
# using the i2c hardware interface. They're not populated by default
# so they're create now ahead of adding the user.
GROUPADD_PARAM:${PN} += "-r netdev; -r i2c; -r gpio"
USERADD_PARAM:${PN} = "--create-home \
                       --groups tty,dialout,i2c,netdev,sudo,gpio \
                       --password '${PASSWORD}' \
                       --user-group gigcompute"

do_install:append() {
    install -d ${D}${sysconfdir}/profile.d
    install -m 0755 ${WORKDIR}/system-binaries.sh ${D}${sysconfdir}/profile.d/system-binaries.sh
}
FILES:${PN} += "${sysconfdir}/profile.d/system-binaries.sh"
