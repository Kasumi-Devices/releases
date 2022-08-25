#!/bin/bash

source ${my_dir}/config.sh

export outdir="${ROM_DIR}/out/target/product/${device}"
BUILD_START=$(date +"%s")
echo "Build started for ${device}"
source build/envsetup.sh
export RELEASES_DIR=$(echo $(cd -))
if [ "${official}" == "true" ]; then
    export LINEAGE_BUILDTYPE="OFFICIAL"
fi
if [ -z "${buildtype}" ]; then
    export buildtype="userdebug"
fi
if [ "${ccache}" == "true" ] && [ -n "${ccache_size}" ]; then
    export USE_CCACHE=1
    ccache -M "${ccache_size}G"
    elif [ "${ccache}" == "true" ] && [ -z "${ccache_size}" ]; then
    echo "Please set the ccache_size variable in your config."
    exit 1
fi
rm "${outdir}"/*$(date +%Y)*.zip*
if [ "${clean}" != "clean" ]; then
    export vibecheck=nohype
    if [ "${clean}" == "installclean" ]; then
        make installclean
    fi
else
    export -n vibecheck
fi
if [ "${bacon}" == "bandori" ]; then
    play live ${rom_vendor_name}_${device}-${buildtype} ${vibecheck}
else
    # Instead of enforcing clean, tie instrument list to a for loop.
    for instrument in ${bacon}; do
        play instrument ${bacon} ${vibecheck}
    done
fi
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))
if [ "${bacon}" == "bandori" ]; then
if [ "${generate_incremental}" == "true" ]; then
    if [ -e "${ROM_DIR}"/*target_files*.zip ]; then
        export old_target_files_exists=true
        export old_target_files_path=$(ls "${ROM_DIR}"/*target_files*.zip | tail -n -1)
    else
        echo "Old target-files package not found, generating incremental package on next build"
    fi
    export new_target_files_path=$(ls "${outdir}"/obj/PACKAGING/target_files_intermediates/*target_files*.zip | tail -n -1)
    if [ "${old_target_files_exists}" == "true" ]; then
        ota_from_target_files -i "${old_target_files_path}" "${new_target_files_path}" "${outdir}"/incremental_ota_update.zip
        export incremental_zip_path=$(ls "${outdir}"/incremental_ota_update.zip | tail -n -1)
    fi
    cp "${new_target_files_path}" "${ROM_DIR}"
fi
export finalzip_path=$(ls "${outdir}"/*$(date +%Y)*.zip | tail -n -1)
if [ "${upload_recovery}" == "true" ]; then
    export img_path=$(ls "${outdir}"/recovery.img | tail -n -1)
fi
export zip_name=$(echo "${finalzip_path}" | sed "s|${outdir}/||")
export tag=$( echo "${zip_name}-$(date +%H%M)" | sed 's|.zip||')
if [ -e "${finalzip_path}" ]; then
    echo "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    echo "Uploading"
    if [ "${internal_build}" != "true" ]; then
        gdrive upload "${finalzip_path}"
    fi
    github-release "${release_repo_github}" "${tag}" "master" "${ROM} for ${device}
    Date: $(env TZ="${timezone}" date)" "${finalzip_path}"
    if [ "${generate_incremental}" == "true" ]; then
        if [ -e "${incremental_zip_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            github-release "${release_repo_github}" "${tag}" "master" "${ROM} for ${device}

            Date: $(env TZ="${timezone}" date)" "${incremental_zip_path}"
            elif [ ! -e "${incremental_zip_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            exit 1
        fi
    fi
    if [ "${upload_recovery}" == "true" ]; then
        if [ -e "${img_path}" ]; then
            github-release "${release_repo_github}" "${tag}" "master" "${ROM} for ${device}

            Date: $(env TZ="${timezone}" date)" "${img_path}"
        else
            echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            exit 1
        fi
    fi
    echo "Uploaded"
    if [ "${upload_recovery}" != "true" ]; then
        if [ "${old_target_files_exists}" != "true" ]; then
            if [ "${internal_build}" == "true" ]; then
                echo "This build is internal and won't have OTA pushed."
            else
                echo "Generating OTA JSON and pushing it..."
                if [ ! -d vendor/kasumiota/.git ]; then
                    rm -rf vendor/kasumiota
                    git clone https://github.com/ProjectKasumi/vendor_kasumiota -b ${branch} vendor/kasumiota
                fi
                rm -rf vendor/kasumi/otagen
                git clone https://github.com/Kasumi-Devices/android_vendor_kasumi_otagen vendor/kasumi/otagen
                pushd vendor/kasumiota
                git pull
                pushd ../kasumi/otagen
                source gen_ota_json.sh
                popd
                git add .
                git config user.name "${GITHUB_NAME}"
                git config user.email "${GITHUB_EMAIL}"
                git commitsigned -m "$(echo -e "Push new OTA for ${device}\n\n* Build type: ${KASUMI_BUILD_TYPE}\n\n* This commit is automated through Jenkins.")" \
             || git commit -s -m "$(echo -e "Push new OTA for ${device}\n\n* Build type: ${KASUMI_BUILD_TYPE}\n\n* This commit is automated through Jenkins.")"
                git push origin HEAD:kasumi-v1 \
             || echo "" \
             && echo "Verbosing JSON. If all pushes failed, ping Beru in #maintainers-discussion on Discord server and she'll push it manually." \
             && echo "" \
             && export tmpvar_json=$(git diff HEAD^ 2>&1 | grep "b/.*json" | sed 's/.*b\///g' | uniq) \
             && echo "INFO: JSON file found at ${tmpvar_json}" \
             && echo "" \
             && cat ${tmpvar_json} \
             && echo ""
                popd
                echo "All done!"
            fi
        fi
    fi
else
    echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    exit 1
fi
else
    echo "Build process ended in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
fi
