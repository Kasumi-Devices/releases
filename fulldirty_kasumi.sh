#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}/config_kasumi.sh"

cd "${ROM_DIR}"

export fulldirty=true

source "${my_dir}/build_kasumi.sh"
