#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}/config_kasumi.sh"

cd "${ROM_DIR}"

source "${my_dir}/sync_kasumi.sh"
