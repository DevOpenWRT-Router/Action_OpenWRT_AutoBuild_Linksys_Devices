#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
##########################################################################################
### ---------------------------------------------------------------------------------- ###
###         [MAKE SURE YOU KNOW WHAT YOUR DOING BEFORE CHANGING ALL THIS]              ###
### ---------------------------------------------------------------------------------- ###

### Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="Eliminater74"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1$"Eliminater74"@' .config

### Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="PureFusion"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1$"PureFusion"@' .config


echo "Seeding .config (enable Target: mvebu cortexa9):"
printf 'CONFIG_TARGET_mvebu=y\nCONFIG_TARGET_mvebu_cortexa9=y\n' >> .config
echo "Seeding .config (enable Signed Packages):"
printf 'CONFIG_SIGNED_PACKAGES=y\n' >> .config
echo "Seeding .config (enable Device: linksys_wrt3200acm):"
printf 'CONFIG_TARGET_mvebu_cortexa9_DEVICE_linksys_wrt3200acm=y\n' >> .config
#echo "Seeding .config (enable ccache):"
#printf 'CONFIG_CCACHE=y\n' >> .config
echo "Seeding .config (enable logs):"
printf 'CONFIG_BUILD_LOG=y\n' >> .config

echo "Checking architecture:"
grep -sq CONFIG_TARGET_mvebu=y .config
echo "property 'libc' set:"
sed -ne '/^CONFIG_LIBC=/ { s!^CONFIG_LIBC="\(.*\)"!\1!; s!^musl$!!; s!.\+!-&!p }' .config

### -----------------------------------[CCACHE HOLD]---------------------------------- ###
#echo "Setting ccache directory:"
#export CCACHE_DIR=openwrt/.ccache
#echo "Fix Sloppiness of ccache:"
#ccache --set-config=sloppiness=file_macro,locale,time_macros
### ---------------------------------------------------------------------------------- ###

### Modify default theme
### Modify  luci-theme-opentomato  as the default theme, you can modify according to your,
### favorite into the other (do not select the default theme theme will automatically,
### have the effect of those changes to)
echo "Changing default luci-theme-bootstap to luci-theme-opentomato"
sed -i 's/luci-theme-bootstrap/luci-theme-opentomato/g' feeds/luci/collections/luci/Makefile

##########################################################################################
### Modify default IP
# sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

### Modify default IP
# sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

###  Modify the default login IP address OpenWrt
# sed -i 's/192.168.1.1/192.168.50.4/g' package/base-files/files/bin/config_generate

### Modify default IP
# sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
### Modify default IP Modify default IP
# sed -i 's/192.168.1.1/192.168.50.1/g' package/base-files/files/bin/config_generate
### Modify default PassWord
# sed -i 's/root::0:0:99999:7:::/root:$1$ScQIGKsX$q0qEf\/tAQ2wpTR6zIUIjo.:0:0:99999:7:::/g' package/base-files/files/etc/shadow

### Modify hostname
# sed -i 's/OpenWrt/Newifi-D2/g' package/base-files/files/bin/config_generate

###  Modify the host name, the OpenWrt-123 modifications you like on the line (not pure digital or use Chinese)
# sed -i '/uci commit system/i\uci set system.@system[0].hostname='OpenWrt-123'' package/lean/default-settings/files/zzz-default-settings

### Modify the version number
# sed -i "s/OpenWrt /PureFusion build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

###  The version number is displayed in its own name (281.67716 million  Build  $ (TZ = UTC-8  DATE  "+% Y.% m.% D")  @  These are the increase of)
# sed -i "s/OpenWrt /Compiled By Liukai On $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

###  version replace
# sed -i 's/-SNAPSHOT/.5/g' include/version.mk

### Set the  password to be empty (you do not need a password to log in when installing the firmware, and then modify the password you want)
# sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

### Replace https-dns-proxy.init file to resolve DNS forwarding after adding passwall compiled firmware with LEDE source 127.0.0.1 # 5053 and 12.0.0.1 # 5054 problem
# curl -fsSL  https://raw.githubusercontent.com/Lienol/openwrt-packages/dev-19.07/net/https-dns-proxy/files/https-dns-proxy.init > feeds/packages/net/https-dns-proxy/files/https-dns-proxy.init

###  Modify the kernel version
# sed -i 's/KERNEL_PATCHVER:=5.10/KERNEL_PATCHVER:=5.4/g' target/linux/mvebu/Makefile
# sed -i 's/KERNEL_TESTING_PATCHVER:=5.10/KERNEL_TESTING_PATCHVER:=5.4/g' target/linux/mvebu/Makefile

### Delete the default password
# sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/lean/default-settings/files/zzz-default-settings

### Change the time zone
# sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# echo "192.168.1.1 wty.lan" >> package/base-files/files/etc/hosts
# rm ./package/feeds/packages/node
# rm ./package/feeds/packages/node-*
# sudo rm -rf ./package/lean/luci-app-wrtbwmon
# sudo rm -rf ./package/libs/libnetfilter-queue/*
# wget -P ./package/libs/libnetfilter-queue/ https://raw.githubusercontent.com/openwrt/packages/master/libs/libnetfilter-queue/Makefile
# pushd po2lmo
# make && sudo make install
# popd
# ./scripts/feeds install libpcap
# ./scripts/feeds install -a -p node



echo "End Of diy-part2.sh"
exit 0
