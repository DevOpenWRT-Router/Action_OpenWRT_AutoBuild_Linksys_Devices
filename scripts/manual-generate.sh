#!/bin/sh
#
#   Copyright (C) 2006-2021
#
# Updated: 03/11/2022
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
########################################################################################
# exec 3>&1 1>>${LOG_FILE}
#
# echo -e "${blue} This is stdout"
# echo -e "${blue} This is stderr" 1>&2
# echo -e "${blue} This is the console (fd 3)" 1>&3
# echo -e "${blue} This is both the log and the console":${reset}" | tee /dev/fd/3
#######################################################################################
# RUN This Bash Script to manually run the following scripts below.
# Copy manual-generate.sh to OpenWRT Clone Directory as well as the other
# scripts listed below.
# Then Run This Script: Once menuconfig is showing,
# Make your special changes then save as device needed:
#
### ============================================= ###

echo "Make sure you have:"
echo "-------------------"
echo "                   "
echo "scripts (Directory)"
echo "       functions.sh"
echo "       fetch_packages.sh"
echo "configs (Directory)"
echo "       feeds.conf.default <-- Can use the default version if you want" 
echo "       wrtmulti.config <-- This is needed regardless unless you change the name"
echo "       patches (Directory)"
echo "                          "
sleep 5
### ------------------------------------------------------------------------------- ###
FILE=functions.sh
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=fetch_packages.sh
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=feeds.conf.default
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=wrtmulti.config
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist. Or Dif device Chosen, Change Name here:"
    exit
fi
FILE=patches
if [ ! -d "$FILE" ]; then
    echo "$FILE Directory not exist."
    exit
fi
### ------------------------------------------------------------------------------- ###
GITHUB_WORKSPACE=$PWD


echo "Cloning from: fetch_packages.sh"
./fetch_packages.sh

echo "------------------------------"
echo "Loading Functions into Memory."
echo "------------------------------"
source ./functions.sh

echo "Delete Not needed or wanted in Packages"
#DELETE_UNWANTED

echo "Delete Duplicate packages"
#DELETE_DUPLICATES

echo "Running: update -a, install -a, uninstall bluld"
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds uninstall bluld

echo "copy wrtmulti.config .config"
cp wrtmulti.config .config

echo "Applying Patches"
git am patches/*.patch

echo "Running: functions.sh"
BUILD_USER_DOMAIN
PRE_DEFCONFIG_ADDONS
CCACHE_SETUP
#DEFAULT_THEME_CHANGE
REMOVE_LANGUAGES

echo "Make Menuconfig"
make menuconfig

echo "Finished: EXIT"
exit 0
