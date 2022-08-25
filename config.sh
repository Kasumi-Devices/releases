#!/bin/bash

export GITHUB_USER="Beru Hinode"
export GITHUB_EMAIL="windowz414@1337.lgbt"
export OLD_GITHUB_USER="$(git config --global --get user.name)"
export OLD_GITHUB_EMAIL="$(git config --global --get user.email)"

export HASTE_SERVER="https://paste.ayokaacr.tk"

# Variable "internal_build" is managed by Jenkins.
# Variable "device" is managed by Jenkins.
export ROM="Project Kasumi"
export ROM_DIR="${HOME}/kasumi-r"
export ROM_VERSION="1.4 \"PoPiPa\""
export official="true"
# Variable "forceclean" is managed by Jenkins.
export local_manifest_url=""
export manifest_url_display="https://github.com/ProjectKasumi/manifest.git" # This manifest will be shown to make sure users are able to sync successfully and build unofficially.
export manifest_url="${manifest_url_display}" # This manifest will be used for syncing to reduce heavy use of Git separately.
export rom_vendor_name="kasumi"
export branch="kasumi-v1"
# Variable "bacon" is managed by Jenkins
# Variable "buildtype" is managed by Jenkins.
# Variable "clean" is managed by Jenkins.
# Variable "no_sync" is managed by Jenkins.
# Variable "sync_projs" is managed by Jenkins.
# Variable "sync_speed" is managed by Jenkins.
export generate_incremental=""
# Variable "upload_recovery" is managed by Jenkins.

export ccache="false"
export ccache_size=""

export jenkins="false"

export release_repo_github="Kasumi-Devices/releases"
export release_repo_id_polycule="42"

export timezone="UTC"
