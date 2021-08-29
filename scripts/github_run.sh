#!/bin/sh -l
#################################################################
# (C) 2021 By Eliminater74 For OpenWRT
# Updated: 20210822
#
#
#################################################################
#
# To run Simple GITHUB commands and prepare Dir
#
#################################################################
set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

SOURCE_DIRECTORY=${{ env.source-directory }}
DESTINATION_GITHUB_USERNAME=${{ env.destination-github-username }}
DESTINATION_REPOSITORY_NAME=${{ env.destination-repository-name }}
USER_EMAIL=${{ env.user-email }}
USER_NAME=${{ env.user-name }}
DESTINATION_REPOSITORY_USERNAME=${{ env.destination-repository-username }}
TARGET_BRANCH=${{ env.target-branch }}
COMMIT_MESSAGE=${{ env.commit-message }}
TARGET_DIRECTORY=${{ env.target-directory }}

echo "[+] Test 1"
echo "[+] $DESTINATION_GITHUB_USERNAME And $DESTINATION_REPOSITORY_NAME Are Listed:"




CLONE_DIR=$(mktemp -d)
TEMP_DIR=$(mktemp -d)

cd openwrt/bin
D="$(date +"%Y.%m.%d-%H%M")"
echo "[+] Creating Directory: $D"
mkdir $D




exit 0
