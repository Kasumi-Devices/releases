#!/bin/bash
if [ "${no_sync}" != "true" ]; then
    echo "Sync started for ${manifest_url}/tree/${branch}"
    if [ "${jenkins}" == "true" ]; then
        telegram -i ${my_dir}/assets/sync1.png -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url_display}/tree/${branch}): [See Progress](${BUILD_URL}console)"
    else
        telegram -i ${my_dir}/assets/sync1.png -M "Sync started for [${ROM} ${ROM_VERSION}](${manifest_url_display}/tree/${branch})"
    fi
    SYNC_START=$(date +"%s")
    if [ -f .repo/local_manifests/default.xml ]; then
        rm .repo/local_manifests/default.xml
    fi
    cores=$(nproc --all)
    if [ "${cores}" -gt "12" ]; then
        cores=12
    fi
    if [ -z "${sync_projs}" ]; then
        repo sync --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune "-j${cores}" -c -v
    else
        repo sync --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune "-j${cores}" -c -v ${sync_projs}
    fi
    syncsuccessful="${?}"
    SYNC_END=$(date +"%s")
    SYNC_DIFF=$((SYNC_END - SYNC_START))
    if [ "${syncsuccessful}" == "0" ]; then
        echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
        telegram -i ${my_dir}/assets/sync3.png -N -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
        source "${my_dir}/build.sh"
    else
        echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
        telegram -i ${my_dir}/assets/sync2.png -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
        exit 1
    fi
else
    echo "Maintainer defined \"no_sync\" as ${no_sync}, skipping..."
    telegram -i ${my_dir}/assets/sync1.png -M "New build was initialized, but maintainer told me not to get sources. Starting build."
    source "${my_dir}/build.sh"
fi; # "${no_sync}" != "true"
