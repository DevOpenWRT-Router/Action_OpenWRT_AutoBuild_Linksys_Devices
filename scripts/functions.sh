#!/bin/bash
#
# Copyright (c) 2021 - 2022 By Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
#
# Updated By Eliminater74 03/20/2022
##########################################################################################
### ---------------------------------------------------------------------------------- ###
###         [MAKE SURE YOU KNOW WHAT YOUR DOING BEFORE CHANGING ALL THIS]              ###
### ---------------------------------------------------------------------------------- ###
##########################################################################################

### Modify default theme
### Modify  luci-theme-opentomato  as the default theme, you can modify according to your,
### favorite into the other (do not select the default theme theme will automatically,
### have the effect of those changes to)
DEFAULT_THEME_CHANGE() {
echo "Changing default luci-theme-bootstap to luci-theme-opentomato"
sed -i 's/luci-theme-bootstrap/luci-theme-opentomato/g' feeds/luci/collections/luci/Makefile
}

###  Modify the default login IP address OpenWrt
MODIFY_DEFAULT_IP() {
sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
}

### Modify default PassWord
MODIFY_DEFAULT_PASSWORD() {
sed -i 's/root::0:0:99999:7:::/root:$1$ScQIGKsX$q0qEf\/tAQ2wpTR6zIUIjo.:0:0:99999:7:::/g' package/base-files/files/etc/shadow
}

### Modify hostname
MODIFY_DEFAULT_HOSTNAME() {
sed -i 's/OpenWrt/Newifi-D2/g' package/base-files/files/bin/config_generate
}

###  version replace
MODIFY_DEFAULT_VERSION() {
sed -i 's/-SNAPSHOT/.5/g' include/version.mk
}

###  Modify the kernel version
MODIFY_DEFAULT_KERNEL_VERSION() {
sed -i 's/KERNEL_PATCHVER:=5.10/KERNEL_PATCHVER:=5.4/g' target/linux/mvebu/Makefile
sed -i 's/KERNEL_TESTING_PATCHVER:=5.10/KERNEL_TESTING_PATCHVER:=5.4/g' target/linux/mvebu/Makefile
}

### Change the time zone
CHANGE_TIMEZONE() {
sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='America/New York'/g" package/base-files/files/bin/config_generate
}

### ------------------------------------------------------------------------------------------------------- ###

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
ccache -sv
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


GETDEVICE() {
if [ $HARDWARE_DEVICE != "wrtmulti" ]; then
  grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
  [ -s DEVICE_NAME ] && echo "DEVICE_NAME=_$(cat DEVICE_NAME)" >> $GITHUB_ENV
else echo "linksys_wrtmulti" > DEVICE_NAME
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
