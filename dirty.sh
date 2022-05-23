#!/bin/bash

export my_dir=$(pwd)

echo "Loading configuration..."
source "${my_dir}/config.sh"

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

GITLAB_HOST="git.polycule.co"

if [ -z "${POLYAMOROUS_TOKEN}" ]; then
    if [ -z "${GITLAB_TOKEN}" ]; then
        if [ -z "${GLAB_TOKEN}" ]; then
            echo "Please set POLYAMOROUS_TOKEN, GITLAB_TOKEN or GLAB_TOKEN before continuing."
            exit 1
        else
            export POLYAMOROUS_TOKEN="${GLAB_TOKEN}"
        fi
    else
        export POLYAMOROUS_TOKEN="${GITLAB_TOKEN}"
    fi
fi

# Email for git
git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"

cd "${ROM_DIR}"

source "${my_dir}/sync.sh"
