#!/bin/bash

source config.sh

export outdir="${ROM_DIR}/out/target/product/${device}"
BUILD_START=$(date +"%s")
echo "Build started for ${device}"
if [ "${jenkins}" == "true" ]; then
    telegram -i ${RELEASES_DIR}/assets/build1.png -M "Build ${BUILD_DISPLAY_NAME} started for ${device}: [See Progress](${BUILD_URL}console)"
else
    telegram -i ${RELEASES_DIR}/assets/build1.png -M "Build started for ${device}"
fi
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
lunch "${rom_vendor_name}_${device}-${buildtype}"
rm "${outdir}"/*$(date +%Y)*.zip*
if [ "${clean}" == "clean" ]; then
    make clean
    make clobber
    elif [ "${clean}" == "installclean" ]; then
    make installclean
fi
(( cores = $(nproc --all) * 2 ))
export cores
make "${bacon}" -j${cores} | tee log.txt
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
    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAACAgUAAxkBAAEHqUxh2FpZphr2MPJY8gABYovHqxtWDIUAAjsBAAJwSPEXgWsq5Pb493IjBA --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
    echo "Uploading"
    gdrive upload "${finalzip_path}"
    github-release "${release_repo_github}" "${tag}" "master" "${ROM} for ${device}
    Date: $(env TZ="${timezone}" date)" "${finalzip_path}"
    curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: ${POLYAMOROUS_TOKEN}" --data '{ "name": "${ROM} ${ROM_VERSION} for ${device}", "tag_name": "${tag}", "ref": "master", "assets": { "links": [{ "name": "${zip_name}", "url": "https://github.com/${release_repo_github}/releases/download/${tag}/${zip_name}", "filepath": "/${zip_name}", "link_type":"package" }] } }' --request POST "https://git.polycule.co/api/v4/projects/${release_repo_id_polycule}/releases"
    if [ "${generate_incremental}" == "true" ]; then
        if [ -e "${incremental_zip_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            github-release "${release_repo_github}" "${tag}" "master" "${ROM} for ${device}

            Date: $(env TZ="${timezone}" date)" "${incremental_zip_path}"
            elif [ ! -e "${incremental_zip_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            telegram -i ${RELEASES_DIR}/assets/build2.png -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            exit 1
        fi
    fi
    if [ "${upload_recovery}" == "true" ]; then
        if [ -e "${img_path}" ]; then
            github-release "${release_repo_github}" "${tag}" "master" "${ROM} for ${device}

            Date: $(env TZ="${timezone}" date)" "${img_path}"
        else
            echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            telegram -i ${RELEASES_DIR}/assets/build2.png -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            exit 1
        fi
    fi
    echo "Uploaded"
    if [ "${upload_recovery}" == "true" ]; then
        if [ "${old_target_files_exists}" == "true" ]; then
            telegram -i ${RELEASES_DIR}/assets/build3.png -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download ROM: ["${zip_name}"]("https://github.com/${release_repo_github}/releases/download/${tag}/${zip_name}")
Download incremental update: ["incremental_ota_update.zip"]("https://github.com/${release_repo_github}/releases/download/${tag}/incremental_ota_update.zip")
            Download recovery: ["recovery.img"]("https://github.com/${release_repo_github}/releases/download/${tag}/recovery.img")"
        else
            telegram -i ${RELEASES_DIR}/assets	build3.png -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download ROM: ["${zip_name}"]("https://github.com/${release_repo_github}/releases/download/${tag}/${zip_name}")
            Download recovery: ["recovery.img"]("https://github.com/${release_repo_github}/releases/download/${tag}/recovery.img")"
        fi
    else
        if [ "${old_target_files_exists}" == "true" ]; then
            telegram -i ${RELEASES_DIR}/assets/build3.png -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download: ["${zip_name}"]("https://github.com/${release_repo_github}/releases/download/${tag}/${zip_name}")
            Download incremental update: ["incremental_ota_update.zip"]("https://github.com/${release_repo_github}/releases/download/${tag}/incremental_ota_update.zip")"
        else
            telegram -i ${RELEASES_DIR}/assets/build3.png -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download: ["${zip_name}"]("https://github.com/${release_repo_github}/releases/download/${tag}/${zip_name}")

Download from official storage: ["${zip_name}"]("https://dl.ayokaacr.tk/4:/${device}/${zip_name}")"

            if [ "${internal_build}" == "true" ]; then
                echo "This build is internal and won't have OTA pushed."
                telegram -M "The build above won't have OTA pushed upon request by maintainer. ^"
            else
                echo "Generating OTA JSON and pushing it..."
                if [ ! -d vendor/kasumiota/.git ]; then
                    git clone https://git.polycule.co/ProjectKasumi/android/vendor_kasumiota vendor/kasumiota
                    pushd vendor/kasumiota
                    git remote add gh https://github.com/ProjectKasumi/android_vendor_kasumiota
                    popd
                fi
                if [ ! -d vendor/kasumi/otagen/.git ]; then
                    git clone https://git.polycule.co/ProjectKasumi/infra/vendor_kasumi_otagen vendor/kasumi/otagen
                fi
                pushd vendor/kasumiota
                git pull
                pushd ../kasumi/otagen
                source gen_ota_json.sh
                popd
                git add .
                git commitsigned -m "$(echo -e "Push new OTA for ${device}\n\n* Build type: ${KASUMI_BUILD_TYPE}\n\n* This commit is automated through Jenkins.")"
                git push
                git push gh kasumi-v1
                popd
                echo "All done!"
                telegram -M "OTA has been pushed. Users should check for updates through Settings > System > Advanced > Updater!"
            fi
        fi
    fi
else
    echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    telegram -i ${RELEASES_DIR}/assets/build2.png -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    exit 1
fi
else
    echo "Build process ended in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    telegram -i ${RELEASES_DIR}/assets/build3.png -M "Build process ended in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds.

This build target wasn't regular one so nothing was uploaded. Check logs for full progress."
fi
