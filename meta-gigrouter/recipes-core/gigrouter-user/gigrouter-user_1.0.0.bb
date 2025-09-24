SUMMARY = "Create the default gigrouter user"
DESCRIPTION = "This recipe creates a default user, named gigrouter, on the target system"
LICENSE = "Apache-2.0"
SECTION = "Custom"
PR = "r0"

inherit useradd

USERADD_PACKAGES = "${PN}"

PASSWORD = "\$6\$sBhZXQYn.XIcQLOn\$CsBLVpDeIlq8iNbF7VGCj5Yqp/P1v3nejonFeh9zPYxvUyhKOVHy7b7YH7YH3g4wQV8uaDh.C1lsRlZIxR2qH1"

USERADD_PARAM:${PN} = "--system --create-home \
                       --groups tty \
                       --password '${PASSWORD}' \
                       --user-group gigrouter"

# Since this recipe doesn't produce any artifacts to install
# onto the rootfs enable the noexec override to avoid installation
# failures.
do_install[noexec] = "1"

# ... however, a side-effect of having no install step, no package
# will be generated which will, in turn, cause a failure to build
# when the image do_rootfs stage is reached. Prevent this by enabling
# a dummy package to be populated.
ALLOW_EMPTY:${PN} = "1"
