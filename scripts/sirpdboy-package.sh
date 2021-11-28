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
    array[ $i ]="$line"
    (( i++ ))
done < <(svn list https://github.com/sirpdboy/sirpdboy-package/trunk)

for i in {1..56}
do
  echo ${array[$i]}
  svn co https://github.com/sirpdboy/sirpdboy-package/trunk/${array[$i]} package/sirpdboy/${array[$i]}
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


echo "From sirpdboy's BUILD packages"

i=0
while read line
do
    array[ $i ]="$line"
    (( i++ ))
done < <(svn list https://github.com/sirpdboy/build/trunk)

for i in {1..25}
do
  echo ${array[$i]}
  svn co https://github.com/sirpdboy/build/trunk/${array[$i]} package/sirpdboy/${array[$i]}
done

rm -rf  package/sirpdboy/autocore
rm -rf  package/sirpdboy/automount
rm -rf  package/sirpdboy/autosamba
rm -rf  package/sirpdboy/default-settings
rm -rf  package/sirpdboy/doc
rm -rf  package/sirpdboy/ksmbd-tools
rm -rf  package/sirpdboy/luci-app-ksmbd
rm -rf  package/sirpdboy/luci-app-samba
rm -rf  package/sirpdboy/luci-app-samba4
rm -rf  package/sirpdboy/miniupnpd
rm -rf  package/sirpdboy/mwan3
rm -rf  package/sirpdboy/samba36
rm -rf  package/sirpdboy/samba4
rm -rf  package/sirpdboy/set
rm -rf  package/sirpdboy/shortcut-fe
echo "END of sirpdboy's packages"
exit 0
