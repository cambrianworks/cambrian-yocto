do_install:append() {
    if [ -f ${D}${sysconfdir}/nvpmodel.conf ]; then
        bbnote "Modifying nvpmodel.conf to set default profile to ID=3"
        sed -i 's/< PM_CONFIG DEFAULT=[0-9] >/< PM_CONFIG DEFAULT=3 >/g' ${D}${sysconfdir}/nvpmodel.conf
        after=$(grep -c '< PM_CONFIG DEFAULT=3 >' "${D}${sysconfdir}/nvpmodel.conf")
        if [ "$after" -eq 0 ]; then
            bberror "Failed to update default PM_CONFIG in nvpmodel.conf"
        fi
    else
        bberror "Failed to locate nvpmodel.conf for patching"
    fi
}
