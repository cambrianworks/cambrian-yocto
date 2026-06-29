do_install:append() {
    if [ -f ${D}${sysconfdir}/nvpmodel.conf ]; then
        bbnote "Modifying nvpmodel.conf to set default profile to ID=3"
        sed -i 's/< PM_CONFIG DEFAULT=[0-9] >/< PM_CONFIG DEFAULT=3 >/g' ${D}${sysconfdir}/nvpmodel.conf
    else
        bberror "Failed to locate nvpmodel.conf for patching"
    fi
}
