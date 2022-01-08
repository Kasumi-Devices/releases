#!/bin/bash
chmod a+x bin/*
export PATH="${PATH}:$(pwd)/bin"

# Uncomment these only if you want the releases repo to be fetched automatically.
export branch=$(git branch | grep \* | cut -d ' ' -f2)
git checkout -- .
git fetch --all
git checkout origin/"${branch}"
git branch -D "${branch}"
git checkout -b "${branch}"

source config.sh

# These variables are all managed by Jenkins;
# GITHUB_TOKEN
# TELEGRAM_TOKEN
# TELEGRAM_CHAT
# BUILD_NUMBER

if [ "${forceclean}" ]; then
    rm -rf "${ROM_DIR}/.repo"
    source clean.sh
else
    if [ ! -d "${ROM_DIR}/out" ]; then
        source clean.sh
    else
        source dirty.sh
    fi
fi
