#!/bin/bash
#
# Copyright (c) 2021 By Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/sirpdboy/sirpdboy-package
# File name: sirpdboy-package.sh
# Description: OpenWRT Packages by sirpdboy (Before Update feeds)
#
# Updated By Eliminater74
################################################################################

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
exit 0
