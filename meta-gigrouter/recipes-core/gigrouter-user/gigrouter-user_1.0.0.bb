SUMMARY = "Create the default gigrouter user"
DESCRIPTION = "This recipe creates a default user, named gigrouter, on the target system"
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

# SHA hash of the gigrouter password
PASSWORD = "\$6\$sBhZXQYn.XIcQLOn\$CsBLVpDeIlq8iNbF7VGCj5Yqp/P1v3nejonFeh9zPYxvUyhKOVHy7b7YH7YH3g4wQV8uaDh.C1lsRlZIxR2qH1"

# netdev allows the user to configure NIC devices. i2c allows for
# using the i2c hardware interface. They're not populated by default
# so they're create now ahead of adding the user.
GROUPADD_PARAM:${PN} += "-r netdev; -r i2c; -r gpio"
USERADD_PARAM:${PN} = "--system --create-home \
                       --groups tty,dialout,i2c,netdev,sudo,gpio \
                       --password '${PASSWORD}' \
                       --user-group gigrouter"

do_install:append() {
    install -d ${D}${sysconfdir}/profile.d
    install -m 0755 ${WORKDIR}/system-binaries.sh ${D}${sysconfdir}/profile.d/system-binaries.sh
}
FILES:${PN} += "${sysconfdir}/profile.d/system-binaries.sh"
