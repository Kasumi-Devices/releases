# Set maintainer-specific variables depending on device.

# Device codename for announcements in channel

export devicecode=$(echo "cat config/vars[device=\"$(echo ${device})\"]/capitalized-codename/text()" | xmllint --shell ${my_dir}/assets/devices.xml | grep -v "^/ >")

# Maintainer name

export mntnrtg=$(echo "cat config/vars[device=\"${device}\"]/maintainer/text()" | xmllint --shell ${my_dir}/assets/devices.xml | grep -v "^/ >")

# Variant

if [ "${KASUMI_BUILD_TYPE}" == "gapps" ]; then
    export variant=GApps
elif [ "${KASUMI_BUILD_TYPE}" == "auroraoss" ]; then
    export variant=AuroraOSS
else
    if [ "${KASUMI_BUILD_TYPE}" != "vanilla" ]; then
        echo -e "\033[0;35mwarning:\033[0m KASUMI_BUILD_TYPE is not set, defaulting to vanilla."
    fi
    export variant=Vanilla
fi

# Add-on status

export addonstat=$(echo "cat config/vars[device=\"${device}\"]/addonstat/text()" | xmllint --shell ${my_dir}/assets/devices.xml | grep -v "^/ >")

# Face unlock status

export facestat=$(echo "cat config/vars[device=\"${device}\"]/facestat/text()" | xmllint --shell ${my_dir}/assets/devices.xml | grep -v "^/ >")

# Credits (by maintainer)

export credits=$(echo "cat config/vars[device=\"${device}\"]/credits/text()" | xmllint --shell ${my_dir}/assets/devices.xml | grep -v "^/ >")
