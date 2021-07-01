#!/bin/bash
#################################################################
# (C) 2021 By Eliminater74 For OpenWRT
# Updated: 20210624
#
#
#################################################################
#
# To find out what kernel version and kernel (M256) Hash
#
#################################################################


cd openwrt
find build_dir/ -name .vermagic -exec cat {} \; > VERMAGIC # Find hash
find build_dir/ -name "linux-*.*.*" -type d > KERNELVERSION # find kernel version
lineA=$(head -n 1 KERNELVERSION) # Read kernel version from file
lineB=$(head -n 1 VERMAGIC) # read kernel hash from file
lineC="${lineA: -13}" # Get last 13 chars from kernel version
lineD="${lineA: -7}" # Get last 7 chars from kernel version
rm -rf VERMAGIC KERNELVERSION # remove both files, Not needed anymore
cd bin/targets/*/*
echo "TARGET_DIR=$PWD" >> $GITHUB_ENV
TARGET_DIR=$PWD
KERNEL_VER=$lineC"-"$lineB # add together to complete
KMOD_DIR=$lineD"-"$lineB # add together to complete
echo "KERNEL_VER=$lineC"-"$lineB" >> $GITHUB_ENV # store in get actions
echo "KMOD_DIR=$lineD"-"$lineB" >> $GITHUB_ENV # store in get actions
echo "------------------------------------------------"
echo "Kernel: $KERNEL_VER" # testing
echo "DIR: $KMOD_DIR"
echo "------------------------------------------------"
echo "------------------------------------------------"
cd ${GITHUB_WORKSPACE}/openwrt
mkdir -p $TARGET_DIR/kmods/$KMOD_DIR
rsync '--include=/kmod-*.ipk' '--exclude=*' -va $TARGET_DIR/packages $TARGET_DIR/kmods/$KMOD_DIR
make -j1 package/index V=s CONFIG_SIGNED_PACKAGES= PACKAGE_SUBDIRS=$TARGET_DIR/kmods/$KMOD_DIR
cd $TARGET_DIR/kmods/$KMOD_DIR
tar -cvzf kmods_$KMOD_DIR.tar.gz ./*
mv kmods_$KMOD_DIR.tar.gz $TARGET_DIR
cd $TARGET_DIR
rm -rf $TARGET_DIR/kmods # Remove kmods folder
cd ${GITHUB_WORKSPACE}/openwrt

echo "--------------------------------------"
echo "CMD: $ARCH_PACKAGES"
echo "CMD: $BOARD"
echo "CMD: $SUBTARGET"
echo "CMD: $TARGET_OPTIMIZATION"
echo "CMD: $TARGET_SUFFIX"
echo "CMD: $BUILD_SUFFIX"
echo "CMD: $SUBDIR"
echo "CMD: $BUILD_SUBDIR"
echo "--------------------------------------"
