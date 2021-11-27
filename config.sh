#!/bin/bash

export RELEASES_DIR=$(pwd)

export GITHUB_USER="alexwcrafter"
export GITHUB_EMAIL="kontakt@ayokaacr.de"

export device="sofiap"
export ROM="Lineage"
export ROM_DIR="${WORKSPACE}/rom"
export ROM_VERSION="19.0"
export official="false"
export local_manifest_url="https://github.com/ACRBuilds/local_manifests/raw/a1f551f3c16c7609a7cbb22e863708a1607d6d20/line-sofiar.xml"
export manifest_url="https://github.com/LineageOS/android"
export rom_vendor_name="lineage"
#export referencedir="ROMNAME"
export branch="lineage-19.0"
export bacon="bacon"
export buildtype="userdebug"
export clean="installclean"
export generate_incremental=""
export upload_recovery="true"

export ccache="false"
export ccache_size=""

export jenkins="true"

export release_repo="ACRBuilds/releases"

export timezone="UTC"

# You'll need to configure these accordingly. Also edit sync.sh accordingly too.
export devicetree="https://github.com/teos-dev/android_device_vestel_teos-lin15" devicepath="device/vestel/teos" devicebranch="lineage-15.1"
export devicetreecommon="https://github.com/teos-dev/android_device_vestel_msm8920-common" devicepathcommon="device/vestel/msm8920-common" devicebranchcommon="lineage-15.1"
export kerneltree="https://github.com/teos-dev/android_kernel_vestel_msm8920" kernelpath="kernel/vestel/msm8920" kernelbranch="lineage-15.1"
export vendortree="https://github.com/teos-dev/android_vendor_vestel-lin15" vendorpath="vendor/vestel" vendorbranch="lineage-15.1"
