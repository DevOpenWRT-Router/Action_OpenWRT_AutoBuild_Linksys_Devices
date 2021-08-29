#!/bin/bash
#################################################################
# (C) 2021 By Eliminater74 For OpenWRT
# Updated: 20210818
#
#
#################################################################
#
# To find out what kernel version and kernel (M256) Hash
#
#################################################################

cd openwrt || exit
find build_dir/ -name .vermagic -exec cat {} \; >VERMAGIC  # Find hash
find build_dir/ -name "linux-5.*.*" -type d >KERNELVERSION # find kernel version
lineA=$(head -n 1 KERNELVERSION)                           # Read kernel version from file
lineB=$(head -n 1 VERMAGIC)                                # read kernel hash from file
lineC="${lineA: -13}"                                      # Get last 13 chars from kernel version
lineD="${lineA: -7}"                                       # Get last 7 chars from kernel version
rm -rf VERMAGIC KERNELVERSION                              # remove both files, Not needed anymore
cd bin/targets/*/* || exit
echo "TARGET_DIR=$PWD" >>$GITHUB_ENV
TARGET_DIR=$PWD
KERNEL_VER=$lineC"-"$lineB                      # add together to complete
KMOD_DIR=$lineD"-"$lineB                        # add together to complete
echo "KERNEL_VER=$lineC"-"$lineB" >>$GITHUB_ENV # store in get actions
echo "KMOD_DIR=$lineD"-"$lineB" >>$GITHUB_ENV   # store in get actions
echo "------------------------------------------------"
echo "Kernel: $KERNEL_VER" # testing
echo "DIR: $KMOD_DIR"
echo "------------------------------------------------"
cd ${GITHUB_WORKSPACE}/openwrt || exit
mkdir -p bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR
rsync '--include=/kmod-*.ipk' '--exclude=*' -va bin/targets/mvebu/cortexa9/packages/ bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR/
make -j32 package/index V=s CONFIG_SIGNED_PACKAGES= PACKAGE_SUBDIRS=bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR/
cd bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR || exit
tar -cvzf kmods_$KMOD_DIR.tar.gz ./*
mv kmods_$KMOD_DIR.tar.gz ${GITHUB_WORKSPACE}/openwrt/bin/targets/mvebu/cortexa9/
cd ${GITHUB_WORKSPACE}/openwrt || exit
# rm -rf bin/targets/mvebu/cortexa9/kmods
# cd ${GITHUB_WORKSPACE}/openwrt

exit 0
