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
    github-release "${release_repo}" "${tag}" "master" "${ROM} for ${device}

    Date: $(env TZ="${timezone}" date)" "${finalzip_path}"
    if [ "${generate_incremental}" == "true" ]; then
        if [ -e "${incremental_zip_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            github-release "${release_repo}" "${tag}" "master" "${ROM} for ${device}

            Date: $(env TZ="${timezone}" date)" "${incremental_zip_path}"
            elif [ ! -e "${incremental_zip_path}" ] && [ "${old_target_files_exists}" == "true" ]; then
            echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            telegram -i ${RELEASES_DIR}/assets/build2.png -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
            exit 1
        fi
    fi
    if [ "${upload_recovery}" == "true" ]; then
        if [ -e "${img_path}" ]; then
            github-release "${release_repo}" "${tag}" "master" "${ROM} for ${device}

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

Download ROM: ["${zip_name}"]("https://github.com/${release_repo}/releases/download/${tag}/${zip_name}")
Download incremental update: ["incremental_ota_update.zip"]("https://github.com/${release_repo}/releases/download/${tag}/incremental_ota_update.zip")
            Download recovery: ["recovery.img"]("https://github.com/${release_repo}/releases/download/${tag}/recovery.img")"
        else
            telegram -i ${RELEASES_DIR}/assets	build3.png -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download ROM: ["${zip_name}"]("https://github.com/${release_repo}/releases/download/${tag}/${zip_name}")
            Download recovery: ["recovery.img"]("https://github.com/${release_repo}/releases/download/${tag}/recovery.img")"
        fi
    else
        if [ "${old_target_files_exists}" == "true" ]; then
            telegram -i ${RELEASES_DIR}/assets/build3.png -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download: ["${zip_name}"]("https://github.com/${release_repo}/releases/download/${tag}/${zip_name}")
            Download incremental update: ["incremental_ota_update.zip"]("https://github.com/${release_repo}/releases/download/${tag}/incremental_ota_update.zip")"
        else
            otacontent=$(echo -n {\"datetime\": `cat $(dirname $1)/ota_metadata | cut -d "=" --output-delimiter "," -f 1,2 | awk -F, -v findex=1 -v value=post-timestamp '$findex == value {print}' | cut -d, -f 2`,\"filename\": \"`basename $1`\",\"id\": \"`sha256sum $1 | awk '{ print $1 }'`\",\"romtype\": \"official\",\"size\": `stat -c%s $1`,\"url\": \"https://github.com/${release_repo}/releases/download/${tag}/${zip_name}\",\"version\": \"1.0\"})
            telegram -i ${RELEASES_DIR}/assets/build3.png -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download: ["${zip_name}"]("https://github.com/${release_repo}/releases/download/${tag}/${zip_name}")

Download from official storage: ["${zip_name}"]("https://dl.ayokaacr.tk/4:/${device}/${zip_name}")"

            echo "Generating OTA JSON and pushing it..."
            if [ ! -d vendor/kasumiota ]; then
                git clone https://github.com/ProjectKasumi/android_vendor_kasumiota vendor/kasumiota
            fi
            pushd vendor/kasumiota
            git pull
            if [ "${KASUMI_BUILD_TYPE}" == "vanilla" ]; then
                echo ${otacontent} > ${device}.json
            else
                if [ ! -d "${KASUMI_BUILD_TYPE}" ]; then
                    mkdir "${KASUMI_BUILD_TYPE}"
                fi
                cd "${KASUMI_BUILD_TYPE}"
                echo ${otacontent} > ${device}.json
                cd -
            fi
            git add .
            git commitsigned -m "$(echo -e "Push new OTA for ${device}\n\n* Build type: ${KASUMI_BUILD_TYPE}\n\n* This commit is automated through Jenkins.")"
            git push
            popd
            telegram -M "OTA has been pushed. Users should check for updates through Settings > System > Advanced > Updater!"
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
