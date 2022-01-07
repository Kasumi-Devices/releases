#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}/config_kasumi.sh"

if [ ! -d "${ROM_DIR}/vendor/priv" ]; then
git clone https://github.com/windowz414/kasumikeys -b master ${ROM_DIR}/vendor/priv
fi

for device in ${devicelist}
do
if [ ! -d "${ROM_DIR}/out" ]; then
    source clean_kasumi.sh
else
    source dirty_kasumi.sh
fi
done
