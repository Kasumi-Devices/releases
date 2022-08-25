#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}"/config.sh

if [ -z "${GITHUB_TOKEN}" ]; then
    if [ ! -f "$(which gh)" ]; then
        echo "Please set GITHUB_TOKEN or install gh and authenticate on GitHub with it before continuing."
        exit 1
    else
        gh auth status --hostname github.com > /dev/null 2>&1
        if [ "$?" != 0 ]; then
            echo "Please set GITHUB_TOKEN or authenticate on GitHub with gh before continuing"
            exit 1
        fi
        echo "GITHUB_TOKEN was unset but gh was authenticated. Using it to set token..."
        export GITHUB_TOKEN=$(gh auth status --show-token 2>&1 | grep Token | sed 's/.* //')
    fi
fi

mkdir -p "${ROM_DIR}"
cd "${ROM_DIR}"
if [ -d "${ROM_DIR}/out" ]; then
source build/envsetup.sh
make clean -j$(nproc --all)
make clobber -j$(nproc --all)
fi

if [ ! -d "${ROM_DIR}/.repo" ]; then
echo "Initializing repository..."
git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"
repo init -u "${manifest_url}" -b "${branch}" --depth 1
git config --global user.email "${OLD_GITHUB_EMAIL}"
git config --global user.name "${OLD_GITHUB_USER}"
fi
source "${my_dir}"/sync.sh
