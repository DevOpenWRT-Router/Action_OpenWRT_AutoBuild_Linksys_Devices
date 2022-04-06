#!/bin/bash
#
# Copyright (c) 2021 - 2022 By Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
#
# Updated By Eliminater74 03/20/2022
################################################################################
# RAN JUST BEFORE BUILD: #
### ---------------------------------------------------------------------------------- ###
###         [MAKE SURE YOU KNOW WHAT YOUR DOING BEFORE CHANGING ALL THIS]              ###
### ---------------------------------------------------------------------------------- ###

BUILD_USER_DOMAIN() {
### Add kernel build user
[ "$(grep "CONFIG_KERNEL_BUILD_USER=" .config)" = "" ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="Eliminater74"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1$"Eliminater74"@' .config

### Add kernel build domain
[ "$(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config)" = "" ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="PureFusion"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1$"PureFusion"@' .config
}

PRE_DEFCONFIG_ADDONS() {
echo "Seeding .config (enable Target: mvebu cortexa9):"
printf 'CONFIG_TARGET_mvebu=y\nCONFIG_TARGET_mvebu_cortexa9=y\n' >> .config
echo "Seeding .config (enable Signed Packages):"
printf 'CONFIG_SIGNED_PACKAGES=y\n' >> .config
echo "Seeding .config (enable logs):"
printf 'CONFIG_BUILD_LOG=y\n' >> .config
echo "Checking architecture:"
grep -sq CONFIG_TARGET_mvebu=y .config
echo "property 'libc' set:"
sed -ne '/^CONFIG_LIBC=/ { s!^CONFIG_LIBC="\(.*\)"!\1!; s!^musl$!!; s!.\+!-&!p }' .config
}

### CCACHE SETUP ###
CCACHE_SETUP() {
echo "Seeding .config (enable ccache):"
printf 'CONFIG_CCACHE=y\n' >> .config
echo "Setting ccache directory:"
export CCACHE_DIR=openwrt/.ccache
echo "Fix Sloppiness of ccache:"
ccache --set-config=sloppiness=file_macro,locale,time_macros
}

CACHE_DIRECTORY_SETUP() {
  if [ ! -d '../staging_dir' ]; then
			mkdir ../staging_dir
		fi
		ln -s ../staging_dir .

		if [ ! -d '../build_dir/host' ]; then
			mkdir ../build_dir/host	-p
			mkdir ./build_dir
		fi
		ln -s ../../build_dir/host build_dir/host
}

### Modify default theme
### Modify  luci-theme-opentomato  as the default theme, you can modify according to your,
### favorite into the other (do not select the default theme theme will automatically,
### have the effect of those changes to)
DEFAULT_THEME_CHANGE() {
echo "Changing default luci-theme-bootstap to luci-theme-opentomato"
# sed -i 's/luci-theme-bootstrap/luci-theme-opentomato/g' feeds/luci/collections/luci/Makefile
}
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
### ------------------------------------------------------------------------------------------------------- ###

GETDEVICE() {
if [ $HARDWARE_DEVICE != "wrtmulti" ]; then
  grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
  [ -s DEVICE_NAME ] && echo "DEVICE_NAME=_$(cat DEVICE_NAME)" >> $GITHUB_ENV
else echo "wrtmulti" > DEVICE_NAME
     [ -s DEVICE_NAME ] && echo "DEVICE_NAME=_$(cat DEVICE_NAME)" >> $GITHUB_ENV
fi
  echo "FILE_DATE=_$(date +"%Y%m%d%H%M")" >> $GITHUB_ENV
}

kernel_version() {
cd openwrt || return
find build_dir/ -name .vermagic -exec cat {} \; >VERMAGIC  # Find hash
find build_dir/ -name "linux-5.*.*" -type d >KERNELVERSION # find kernel version
kv=$(tail -n +2 KERNELVERSION | sed 's/.*x-//')
vm=$(head -n 1 VERMAGIC)                                # read kernel hash from file                                     # Get last 7 chars from kernel version
rm -rf VERMAGIC KERNELVERSION                              # remove both files, Not needed anymore
cd bin/targets/*/* || return
echo "TARGET_DIR=$PWD" >>"$GITHUB_ENV"
TARGET_DIR=$PWD
KERNEL_VER=$kv"-"$vm                      # add together to complete
KMOD_DIR=$kv"-"$vm                        # add together to complete
echo "KERNEL_VER=$kv"-"$vm" >>"$GITHUB_ENV" # store in get actions
echo "KMOD_DIR=$kv"-"$vm" >>"$GITHUB_ENV"   # store in get actions
echo "------------------------------------------------"
echo "Kernel: $KERNEL_VER" # testing
echo "DIR: $KMOD_DIR"
echo "------------------------------------------------"
echo "$KMOD_DIR" >> "$GITHUB_WORKSPACE"/openwrt/kmod
cat kmod
}

package_archive() {
cd "$GITHUB_WORKSPACE"/openwrt || return
mkdir -p bin/targets/mvebu/cortexa9/kmods/"$KMOD_DIR"
rsync '--include=/kmod-*.ipk' '--exclude=*' -va bin/targets/mvebu/cortexa9/packages/ bin/targets/mvebu/cortexa9/kmods/"$KMOD_DIR"/
make -j32 package/index V=s CONFIG_SIGNED_PACKAGES= PACKAGE_SUBDIRS=bin/targets/mvebu/cortexa9/kmods/"$KMOD_DIR"/
cd bin/targets/mvebu/cortexa9/kmods/"$KMOD_DIR" || exit
tar -cvzf kmods_"$KMOD_DIR".tar.gz ./*
mv kmods_"$KMOD_DIR".tar.gz "$GITHUB_WORKSPACE"/openwrt/bin/targets/mvebu/cortexa9/
cd "$GITHUB_WORKSPACE"/openwrt || return
}
### ------------------------------------------------------------------------------------------------------- ###

"$1";
echo "End of Functions.sh"
exit 0
