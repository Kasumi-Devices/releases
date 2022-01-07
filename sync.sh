#!/bin/bash
echo "Sync started for ${manifest_url}/tree/${branch}"
if [ "${jenkins}" == "true" ]; then
    telegram -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url}/tree/${branch}): [See Progress](${BUILD_URL}console)"
else
    telegram -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url}/tree/${branch})"
fi
SYNC_START=$(date +"%s")
if [[ ! -z ${local_manifest_url} ]]; then
    if [ "${official}" != "true" ]; then
        mkdir -p .repo/local_manifests
        if [ -f .repo/local_manifests/default.xml ]; then
            rm .repo/local_manifests/default.xml
        fi
        wget "${local_manifest_url}" -O .repo/local_manifests/default.xml
    fi
else
    # git clone ${devicetree} -b ${devicebranch} ${devicepath}
    # git clone ${devicetreecommon} -b ${devicebranchcommon} ${devicepathcommon}
    # git clone ${kerneltree} -b ${kernelbranch} ${kernelpath}
    # git clone ${vendortree} -b ${vendorbranch} ${vendorpath}
    echo ""
fi
cores=$(nproc --all)
if [ "${cores}" -gt "12" ]; then
    cores=12
fi
repo sync --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune "-j${cores}" -c -v
syncsuccessful="${?}"
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ "${syncsuccessful}" == "0" ]; then
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    source "${my_dir}/build.sh"
else
    echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    exit 1
fi
