#!/bin/bash

export RELEASES_DIR=$(pwd)

export GITHUB_USER="Beru Shinsetsu"
export GITHUB_EMAIL="windowz414@1337.lgbt"

export HASTE_SERVER="https://paste.ayokaacr.tk"

# Variable "internal_build" is managed by Jenkins.
# Variable "device" is managed by Jenkins.
export ROM="Project Kasumi"
export ROM_DIR="${WORKSPACE}/kasumi"
export ROM_VERSION="v1.0"
export official="true"
# Variable "forceclean" is managed by Jenkins.
export local_manifest_url=""
export manifest_url_display="https://git.polycule.co/ProjectKasumi/android/manifest.git" # This manifest will be shown to make sure users are able to sync successfully and build unofficially.
export manifest_url="https://git.polycule.co/ProjectKasumi/infra/manifest.git" # This manifest will be used for syncing to reduce heavy use of Git separately.
export rom_vendor_name="kasumi"
export branch="kasumi-v1"
# Variable "bacon" is managed by jenkins
# Variable "buildtype" is managed by Jenkins.
# Variable "clean" is managed by Jenkins.
# Variable "no_sync" is managed by Jenkins.
# Variable "sync_projs" is managed by Jenkins.
export generate_incremental=""
# Variable "upload_recovery" is managed by Jenkins.

export ccache="false"
export ccache_size=""

export jenkins="true"

export release_repo_github="Kasumi-Devices/releases"
export release_repo_id_polycule="42"

export timezone="UTC"
