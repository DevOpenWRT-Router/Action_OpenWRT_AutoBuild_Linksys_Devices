#!/bin/sh
#
#   Copyright (C) 2006-2021
#
# Updated: 11/28/2021
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
echo "       diy-part1.sh"
echo "       diy-part2.sh"
echo "       luci_themes.sh"
echo "       DevOpenWRT-Router.sh"
echo "       lean_packages.sh"
echo "       sirpdboy-package.sh"
echo "configs (Directory)"
echo "       feeds.conf.default"
echo "       wrt3200acm.config"
echo "       patches (Directory)"
echo "                          "
sleep 5
### ------------------------------------------------------------------------------- ###
FILE=diy-part1.sh
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=diy-part2.sh
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=luci_themes.sh
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=DevOpenWRT-Router.sh
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=lean_packages.sh
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=sirpdboy-package.sh
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=feeds.conf.default
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    exit
fi
FILE=wrt3200acm.config
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

echo "Running: diy-part1.sh"
./diy-part1.sh

echo "Cloning from: luci_themes.sh"
./luci_themes.sh

echo "Cloning from: DevOpenWRT-Router.sh"
./DevOpenWRT-Router.sh

echo "Cloning from: lean_packages.sh"
./lean_packages.sh

echo "Cloning from: sirpdboy-package.sh"
./sirpdboy-package.sh

echo "Running: update -a, install -a, uninstall bluld"
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds uninstall bluld

echo "copy wrt3200acm.config .config"
cp wrt3200acm.config .config

echo "Applying Patches"
git am patches/*.patch

echo "Running: diy-part2.sh"
./diy-part2.sh

echo "Make Menuconfig"
make menuconfig

echo"Finished: EXIT"
exit 0
