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

echo "[+] Test 1"

cd openwrt/bin
D="$(date +"%Y.%m.%d-%H%M")"
echo "[+] Creating Directory: $D"
mkdir $D




exit 0
