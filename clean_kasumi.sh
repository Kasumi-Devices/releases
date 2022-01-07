#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}"/config_kasumi.sh

mkdir -p "${ROM_DIR}"
cd "${ROM_DIR}"
if [ -d "${ROM_DIR}/out" ]; then
make clean -j$(nproc --all)
make clobber -j$(nproc --all)
fi

if [ ! -d "${ROM_DIR}/.repo" ]; then
echo "Initializing repository..."
repo init -u "${manifest_url}" -b "${branch}" --depth 1
fi
source "${my_dir}"/sync_kasumi.sh
