#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Updated By Eliminater74 06/18/2021
################################################################################

### Uncomment a feed source
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

### luci-app-filebrowser
git clone https://github.com/xiaozhuai/luci-app-filebrowser.git package/luci-app-filebrowser
### luci-app-eqos
git clone https://github.com/MapesxGM/luci-app-eqos.git package/luci-app-eqos
### luci-app-onliner
git clone https://github.com/rufengsuixing/luci-app-onliner.git package/luci-app-onliner
### luci-app-fileassistant
git clone https://github.com/gztingting/luci-app-fileassistant.git package/luci-app-fileassistant
### luci-app-wifimac
git clone https://github.com/qianmuyixiao/luci-app-wifimac.git package/luci-app-wifimac
### luci-app-telegrambot
git clone https://github.com/koshev-msk/luci-app-telegrambot.git package/luci-app-telegrambot
### luci-app-observatory
git clone https://gitlab.com/serenascopycats/luci-app-observatory.git package/luci-app-observatory
### luci-app-shortcutmenu
git clone https://github.com/doushang/luci-app-shortcutmenu.git package/luci-app-shortcutmenu
### luci-app-rtorrent-js
git clone https://github.com/wolandmaster/luci-app-rtorrent-js.git package/luci-app-rtorrent-js
### luci-app-rtorrent
git clone https://github.com/wolandmaster/luci-app-rtorrent.git package/luci-app-rtorrent

### luci-app-diskman
## A Simple Disk Manager for LuCI, support disk partition and format, support raid / btrfs-raid / btrfs-snapshot
mkdir -p package/luci-app-diskman
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile -O package/luci-app-diskman/Makefile
mkdir -p package/parted
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile

### luci-app-dnsfilter
git clone https://github.com/garypang13/luci-app-dnsfilter.git package/luci-app-dnsfilter

### luci-app-usbnet
git clone https://github.com/a920025608/luci-app-usbnet.git package/luci-app-usbnet
git clone https://github.com/a920025608/usbnet.git package/usbnet

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


echo "End of diy-part1.sh"
exit 0
