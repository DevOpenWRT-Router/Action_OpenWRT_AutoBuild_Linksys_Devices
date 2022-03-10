#!/bin/bash
#
# Copyright (c) 2021 By Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/coolsnowwolf/lede
# File name: lean_packages.sh
# Description: OpenWRT Packages by coolsnowwolf (Before Update feeds)
#
# Updated By Eliminater74
################################################################################

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
exit 0
