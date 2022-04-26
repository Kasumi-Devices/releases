#!/bin/bash
if [ "${no_sync}" != "true" ]; then
    echo "Sync started for ${manifest_url}/tree/${branch}"
    SYNC_START=$(date +"%s")
    if [ -f .repo/local_manifests/default.xml ]; then
        rm .repo/local_manifests/default.xml
    fi
    repo sync build/make external/tuuru vendor/kasumi
    source build/envsetup.sh
    reposync ${sync_speed} ${sync_projs}
    syncsuccessful="${?}"
    SYNC_END=$(date +"%s")
    SYNC_DIFF=$((SYNC_END - SYNC_START))
    if [ "${syncsuccessful}" == "0" ]; then
        echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
        source "${my_dir}/build.sh"
    else
        echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
        exit 1
    fi
else
    echo "Maintainer defined \"no_sync\" as ${no_sync}, skipping..."
    source "${my_dir}/build.sh"
fi; # "${no_sync}" != "true"
