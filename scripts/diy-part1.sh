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
### luci-app-shortcutmenu
git clone https://github.com/doushang/luci-app-shortcutmenu.git package/luci-app-shortcutmenu
### luci-app-rtorrent
git clone https://github.com/wolandmaster/luci-app-rtorrent.git package/luci-app-rtorrent
### luci-app-zospusher
git clone https://github.com/zhengwenxiao/luci-app-zospusher.git package/luci-app-zospusher
### helmiwrt-packages
git clone https://github.com/helmiau/helmiwrt-packages.git package/helmiwrt-packages


### luci-app-control-weburl
git clone https://github.com/gdck/luci-app-control-weburl.git package/luci-app-control-weburl
### luci-app-unlocker
git clone https://gitlab.com/Nooblord/luci-app-unlocker.git package/luci-app-unlocker

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


### ------------------------------------------------------------------------------------------ ###
### DISABLED ###
### luci-app-telegrambot
# git clone https://github.com/koshev-msk/luci-app-telegrambot.git package/luci-app-telegrambot
### openwrt-telegram-bot
# git clone https://github.com/koshev-msk/openwrt-telegram-bot.git package/openwrt-telegram-bot
### luci-app-change-mac
# git clone https://github.com/muink/luci-app-change-mac.git package/luci-app-change-mac
### rgmac
# git clone https://github.com/muink/rgmac.git package/rgmac

echo "End of diy-part1.sh"
exit 0
