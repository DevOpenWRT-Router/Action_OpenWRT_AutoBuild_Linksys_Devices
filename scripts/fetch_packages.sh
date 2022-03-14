#!/bin/bash
#
# Copyright (c) 2022 By Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# File name: fetch_packages.sh
# Description: OpenWRT Packages
#
# Updated By Eliminater74
################################################################################

### -------------------------------------------------------------------------------------------------------------- ###
echo " Fetching All Personal Repo's"
echo "Fetching From DevOpenWRT-Router:"
### luci-app-log
git clone https://github.com/DevOpenWRT-Router/luci-app-log.git package/luci-app-log
### luci-app-tn-logview
git clone https://github.com/DevOpenWRT-Router/luci-app-tn-logview.git package/luci-app-tn-logview
### syslog_fc
git clone https://github.com/DevOpenWRT-Router/syslog_fc.git package/syslog_fc

### luci-app-interfaces-statistics
git clone https://github.com/DevOpenWRT-Router/luci-app-interfaces-statistics.git package/luci-app-interfaces-statistics
### luci-app-cpu-status
git clone https://github.com/DevOpenWRT-Router/luci-app-cpu-status.git package/luci-app-cpu-status
### luci-app-temp-status
git clone https://github.com/DevOpenWRT-Router/luci-app-temp-status.git package/luci-app-temp-status
### luci-app-rebootschedule
git clone https://github.com/DevOpenWRT-Router/luci-app-rebootschedule.git package/luci-app-rebootschedule
### luci-app-timecontrol
git clone https://github.com/DevOpenWRT-Router/luci-app-timecontrol.git package/luci-app-timecontrol
### luci-app-cpulimit
git clone https://github.com/DevOpenWRT-Router/luci-app-cpulimit.git package/luci-app-cpulimit
### luci-app-mqos
git clone https://github.com/DevOpenWRT-Router/luci-app-mqos.git package/luci-app-mqos
### luci-app-disks-info
git clone https://github.com/DevOpenWRT-Router/luci-app-disks-info.git package/luci-app-disks-info
### NetSpeedTest
git clone https://github.com/DevOpenWRT-Router/netspeedtest.git package/NetSpeedTest
### luci-app-netdata A
git clone https://github.com/DevOpenWRT-Router/luci-app-netdata-A.git package/luci-app-netdata
### luci-app-netdata B
## git clone https://github.com/DevOpenWRT-Router/luci-app-netdata-B.git package/luci-app-netdata
### luci-app-observatory
git clone https://github.com/DevOpenWRT-Router/luci-app-observatory.git package/luci-app-observatory
### luci-app-rtorrent-js
git clone https://github.com/DevOpenWRT-Router/luci-app-rtorrent-js.git package/luci-app-rtorrent-js
### luci-app-autowms
git clone https://github.com/DevOpenWRT-Router/luci-app-autowms.git package/luci-app-autowms
### luci-default-settings
git clone https://github.com/DevOpenWRT-Router/luci-default-settings.git package/luci-default-settings

### luci-app-tn-ttyd DO NOT USE
# git clone https://github.com/DevOpenWRT-Router/luci-app-tn-ttyd.git package/luci-app-tn-ttyd
### luci-app-tn-shellinabox
# git clone https://github.com/DevOpenWRT-Router/luci-app-tn-shellinabox.git package/luci-app-tn-shellinabox
### luci-app-tn-watchdog
# git clone https://github.com/DevOpenWRT-Router/luci-app-tn-watchdog.git package/luci-app-tn-watchdog
### luci-app-tn-netports
# git clone https://github.com/DevOpenWRT-Router/luci-app-tn-netports.git package/luci-app-tn-netports
echo "END Fetching From DevOpenWRT-Router:"


### Uncomment a feed source
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

echo "Fetching From unSorted Repo's:"
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

echo "END Fetching From unSorted Repo's:"
echo "End of Fetching All Personal Repos"
### -------------------------------------------------------------------------------------------------------------- ###

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






### -------------------------------------------------------------------------------------------------------------- ###
echo "Downloading coolsnowwolf's lean packages"

i=0
while read line
do
    packages[ $i ]="$line"
    (( i++ ))
done < <(svn list https://github.com/coolsnowwolf/lede/trunk/package/lean)

## get length of $packages array
len=${#packages[@]}

## Use bash for loop
for (( i=0; i<$len; i++ ))
do
  echo "${packages[$i]}"
  svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/${packages[$i]} package/lean/${packages[$i]}
done

rm -rf package/lean/UnblockNeteaseMusic
rm -rf package/lean/UnblockNeteaseMusicGo
rm -rf package/lean/automount
rm -rf package/lean/autosamba
rm -rf package/lean/csstidy
rm -rf package/lean/default-settings
rm -rf package/lean/frp
rm -rf package/lean/luci-app-dnsfilter
rm -rf package/lean/luci-app-frpc
rm -rf package/lean/luci-app-frps
rm -rf package/lean/luci-app-netdata
rm -rf package/lean/luci-app-nft-qos
rm -rf package/lean/luci-app-samba4
rm -rf package/lean/luci-app-ttyd
rm -rf package/lean/luci-app-unblockmusic
rm -rf package/lean/luci-lib-docker
rm -rf package/lean/luci-proto-bonding
rm -rf package/lean/luci-theme-argon
rm -rf package/lean/luci-theme-netgear
rm -rf package/lean/mt # Some Error Keeps happening #

echo "END of coolsnowwolf's lean packages"
### Needed for qBittorrent qt5
echo "Add coolsnowwolf's libdouble-conversion"
svn co https://github.com/coolsnowwolf/lede/trunk/package/libs/libdouble-conversion package/libs/libdouble-conversion
echo "END coolsnowwolf's libdouble-conversion"
### Use lede's edition of mwlwifi
echo "Add coolsnowwolf's edition of mwlwifi"
rm -rf ./package/kernel/mwlwifi # Delete openWRT's version replace with sync lede
svn co https://github.com/coolsnowwolf/lede/trunk/package/kernel/mwlwifi package/kernel/mwlwifi
echo "END coolsnowwolf's edition of mwlwifi"

### -------------------------------------------------------------------------------------------------------------- ###

echo "Downloading sirpdboy's packages"
i=0
while read line
do
    packages[ $i ]="$line"
    (( i++ ))
done < <(svn list https://github.com/sirpdboy/sirpdboy-package/trunk)

## get length of $packages array
len=${#packages[@]}

## Use bash for loop
for (( i=0; i<$len; i++ ))
do
  echo "${packages[$i]}"
  svn co https://github.com/sirpdboy/sirpdboy-package/trunk/${packages[$i]} package/sirpdboy/${packages[$i]}
done

rm -rf  package/sirpdboy/adguardhome
rm -rf  package/sirpdboy/doc
rm -rf  package/sirpdboy/luci-app-access-control ## NEEDS FIXED
rm -rf  package/sirpdboy/luci-app-baidupcs-web
rm -rf  package/sirpdboy/luci-app-chinadns-ng
rm -rf  package/sirpdboy/luci-app-cpulimit
rm -rf  package/sirpdboy/luci-app-dockerman
rm -rf  package/sirpdboy/luci-app-easymesh
rm -rf  package/sirpdboy/luci-app-netdata
rm -rf  package/sirpdboy/luci-app-netspeedtest
rm -rf  package/sirpdboy/luci-app-onliner
rm -rf  package/sirpdboy/luci-app-ramfree
rm -rf  package/sirpdboy/luci-app-rebootschedule
rm -rf  package/sirpdboy/luci-app-smartdns
rm -rf  package/sirpdboy/luci-app-socat
rm -rf  package/sirpdboy/luci-app-timecontrol
rm -rf  package/sirpdboy/luci-app-wrtbwmon
rm -rf  package/sirpdboy/luci-theme-argon_new
rm -rf  package/sirpdboy/luci-theme-atmaterial
rm -rf  package/sirpdboy/luci-theme-btmod
rm -rf  package/sirpdboy/luci-theme-edge
rm -rf  package/sirpdboy/luci-theme-ifit
rm -rf  package/sirpdboy/luci-theme-opentomato
rm -rf  package/sirpdboy/luci-theme-opentomcat
rm -rf  package/sirpdboy/luci-theme-opentopd
rm -rf  package/sirpdboy/netdata
rm -rf  package/sirpdboy/speedtest-cli ## NEEDS FIXED

echo "END of sirpdboy's packages"

echo "From sirpdboy's BUILD packages"

i=0
while read line
do
    packages[ $i ]="$line"
    (( i++ ))
done < <(svn list https://github.com/sirpdboy/build/trunk)

## get length of $packages array
len=${#packages[@]}

## Use bash for loop
for (( i=0; i<$len; i++ ))
do
  echo "${packages[$i]}"
  svn co https://github.com/sirpdboy/build/trunk/${packages[$i]} package/sirpdboy/${packages[$i]}
done

rm -rf  package/sirpdboy/autocore
rm -rf  package/sirpdboy/automount
rm -rf  package/sirpdboy/autosamba-samba4
rm -rf  package/sirpdboy/default-settings # using a dif
rm -rf  package/sirpdboy/doc # not a package
rm -rf  package/sirpdboy/gcc # not a package
rm -rf  package/sirpdboy/ksmbd-tools
rm -rf  package/sirpdboy/luci-app-ksmbd
rm -rf  package/sirpdboy/luci-app-samba
rm -rf  package/sirpdboy/luci-app-samba4
rm -rf  package/sirpdboy/miniupnpd
rm -rf  package/sirpdboy/mwan3
rm -rf  package/sirpdboy/samba36
rm -rf  package/sirpdboy/samba4
rm -rf  package/sirpdboy/my-autocore
rm -rf  package/sirpdboy/mycore
rm -rf  package/sirpdboy/pass
rm -rf  package/sirpdboy/set # Not a package
rm -rf  package/sirpdboy/socat

echo "END of sirpdboy's Build packages"

### -------------------------------------------------------------------------------------------------------------- ###

exit 0
