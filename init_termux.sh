#!/bin/bash
export my_dir=$(pwd)
cd ~
echo "Downloading dependencies..."
git clone https://github.com/akhilnarang/scripts --depth 1
cd scripts
echo "Installing dependencies..."
source setup/android_build_env.sh
cd ..
rm -rf scripts
pkg purge openjdk-11* -y
pkg install openjdk-8-jdk -y
cd "${my_dir}"
if [ ! -f /usr/bin/telegram ]; then
    install bin/telegram /data/data/com.termux/files/usr/bin
elif [ ! -f /usr/bin/github-release ]; then
    install bin/github-release /data/data/com.termux/files/usr/bin
fi
