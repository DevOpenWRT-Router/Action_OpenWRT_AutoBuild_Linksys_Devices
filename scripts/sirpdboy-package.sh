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

svn co https://github.com/sirpdboy/sirpdboy-package/trunk/adguardhome package/sirpdboy/adguardhome
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/cpulimit package/sirpdboy/cpulimit
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/doc package/sirpdboy/doc
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/iptvhelper package/sirpdboy/iptvhelper
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/lua-maxminddb package/sirpdboy/lua-maxminddb
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-access-control package/sirpdboy/luci-app-access-control
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-adguardhome package/sirpdboy/luci-app-adguardhome
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-advanced package/sirpdboy/luci-app-advanced
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-airwhu package/sirpdboy/luci-app-airwhu
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-aliddns package/sirpdboy/luci-app-aliddns
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-baidupcs-web package/sirpdboy/luci-app-baidupcs-web
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-chinadns-ng package/sirpdboy/luci-app-chinadns-ng
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-control-timewol package/sirpdboy/luci-app-control-timewol
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-control-weburl package/sirpdboy/luci-app-control-weburl
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-cpulimit package/sirpdboy/luci-app-cpulimit
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-dnspod package/sirpdboy/luci-app-dnspod
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-dnsto package/sirpdboy/luci-app-dnsto
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-dockerman package/sirpdboy/luci-app-dockerman
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-easymesh package/sirpdboy/luci-app-easymesh
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-eqos package/sirpdboy/luci-app-eqos
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-ipsec-server package/sirpdboy/luci-app-ipsec-server
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-iptvhelper package/sirpdboy/luci-app-iptvhelper
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-koolddns package/sirpdboy/luci-app-koolddns
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-koolproxyR package/sirpdboy/luci-app-koolproxyR
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-mentohust package/sirpdboy/luci-app-mentohust
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-netdata package/sirpdboy/luci-app-netdata
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-netspeedtest package/sirpdboy/luci-app-netspeedtest
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-onliner package/sirpdboy/luci-app-onliner
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-poweroffdevice package/sirpdboy/luci-app-poweroffdevice
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-pppoe-server package/sirpdboy/luci-app-pppoe-server
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-pptp-server package/sirpdboy/luci-app-pptp-server
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-pushbot package/sirpdboy/luci-app-pushbot
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-ramfree package/sirpdboy/luci-app-ramfree
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-rebootschedule package/sirpdboy/luci-app-rebootschedule
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-smartdns package/sirpdboy/luci-app-smartdns
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-socat package/sirpdboy/luci-app-socat
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-switch-lan-play package/sirpdboy/luci-app-switch-lan-play
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-tencentddns package/sirpdboy/luci-app-tencentddns
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-timecontrol package/sirpdboy/luci-app-timecontrol
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-wolplus package/sirpdboy/luci-app-wolplus
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-wrtbwmon package/sirpdboy/luci-app-wrtbwmon
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-theme-argon_new package/sirpdboy/luci-theme-argon_new
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-theme-atmaterial package/sirpdboy/luci-theme-atmaterial
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-theme-btmod package/sirpdboy/luci-theme-btmod
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-theme-edge package/sirpdboy/luci-theme-edge
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-theme-ifit package/sirpdboy/luci-theme-ifit
# svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-theme-opentomato package/sirpdboy/luci-theme-opentomato
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-theme-opentomcat package/sirpdboy/luci-theme-opentomcat
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-theme-opentopd package/sirpdboy/luci-theme-opentopd
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/mentohust package/sirpdboy/mentohust
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/netdata package/sirpdboy/netdata
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/smartdns-le package/sirpdboy/smartdns-le
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/smartdns package/sirpdboy/smartdns
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/socat package/sirpdboy/socat
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/speedtest-cli package/sirpdboy/speedtest-cli
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/switch-lan-play package/sirpdboy/switch-lan-play
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/wrtbwmon package/sirpdboy/wrtbwmon
echo "END of sirpdboy's packages"
exit 0
