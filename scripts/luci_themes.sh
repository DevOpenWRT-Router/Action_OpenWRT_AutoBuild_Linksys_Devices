#!/bin/bash
#
# Copyright (c) 2021 Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
#
# File name: luci_themes.sh
# Description: OpenWrt Luci Custom Themes
#
# Updated By Eliminater74 08/14/2021
################################################################################

### ----------------------------------------------------------------------- ###
### THEMES ###
### new argon theme
git clone -b master https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
### New argon theme control program
git clone -b master https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
### luci-theme-opentomcat
# git clone https://github.com/chaoxiaozhu/luci-theme-opentomcat.git package/luci-theme-opentomcat
### luci-theme-rosy
# git clone https://github.com/rosywrt/luci-theme-rosy.git package/luci-theme-rosy
### luci-theme-netgear
# git clone https://github.com/ysoyipek/luci-theme-netgear.git package/luci-theme-netgear
### luci-theme-edge2 ###
# git clone -b main https://github.com/YL2209/luci-theme-edge2.git package/luci-theme-edge2
### luci-theme-opentopd thme openwrt theme
# git clone https://github.com/sirpdboy/luci-theme-opentopd.git package/luci-theme-opentopd
### btmod theme
# git clone https://github.com/sirpdboy/luci-theme-btmod.git package/luci-theme-btmob
### luci-theme-opentomcat
# git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat
### luci-theme-netgear
# git clone https://github.com/i028/luci-theme-netgear.git package/luci-theme-netgear
### luci-theme-ifit
# git clone https://github.com/YL2209/luci-theme-ifit.git package/luci-theme-ifit
### luci-theme-surfboard
# git clone https://github.com/SURFBOARD-ONE/luci-theme-surfboard.git package/luci-theme-surfboard
### luci-theme-atmaterial
# git clone https://github.com/miccjing/luci-theme-atmaterial.git package/luci-theme-atmaterial
### luci-theme-mcat
# git clone https://github.com/fszok/luci-theme-mcat.git package/luci-theme-mcat
### luci-theme-fate
# git clone https://github.com/fatelpc/luci-theme-fate.git package/luci-theme-fate
### ----------------------------------------------------------------------- ###

echo "End of luci_themes.sh"
exit 0
