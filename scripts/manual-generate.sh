#!/bin/sh
#
#   Copyright (C) 2006-2021
#
# Updated: 12/20/2020
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
./diy-part1.sh
./luci_themes.sh
./DevOpenWRT-Router.sh
./lean_packages.sh
./sirpdboy-package.sh
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds uninstall bluld
cp wrt3200acm.config .config
git am patches/*.patch
./diy-part2.sh
make menuconfig
exit 0
