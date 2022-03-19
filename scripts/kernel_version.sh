#!/bin/bash
#################################################################
# (C) 2022 By Eliminater74 For OpenWRT
# Updated: 03/18/2022
#
#
#################################################################
#
# To find out what kernel version and kernel (M256) Hash
#
#################################################################

kernel_version() {
cd openwrt || exit
find build_dir/ -name .vermagic -exec cat {} \; >VERMAGIC  # Find hash
find build_dir/ -name "linux-5.*.*" -type d >KERNELVERSION # find kernel version
kv=$(tail -n +2 KERNELVERSION | sed 's/.*x-//')
vm=$(head -n 1 VERMAGIC)                                # read kernel hash from file                                     # Get last 7 chars from kernel version
rm -rf VERMAGIC KERNELVERSION                              # remove both files, Not needed anymore
cd bin/targets/*/* || exit
echo "TARGET_DIR=$PWD" >>$GITHUB_ENV
TARGET_DIR=$PWD
KERNEL_VER=$kv"-"$vm                      # add together to complete
KMOD_DIR=$kv"-"$vm                        # add together to complete
echo "KERNEL_VER=$kv"-"$vm" >>$GITHUB_ENV # store in get actions
echo "KMOD_DIR=$kv"-"$vm" >>$GITHUB_ENV   # store in get actions
echo "------------------------------------------------"
echo "Kernel: $KERNEL_VER" # testing
echo "DIR: $KMOD_DIR"
echo "------------------------------------------------"
ls
}

if [ "$1" == "TEST" ]; then
  echo "THIS WORKED LIKE IT SHOULD"
fi

package_archive() {
cd ${GITHUB_WORKSPACE}/openwrt || exit
mkdir -p bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR
rsync '--include=/kmod-*.ipk' '--exclude=*' -va bin/targets/mvebu/cortexa9/packages/ bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR/
make -j32 package/index V=s CONFIG_SIGNED_PACKAGES= PACKAGE_SUBDIRS=bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR/
cd bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR || exit
tar -cvzf kmods_$KMOD_DIR.tar.gz ./*
mv kmods_$KMOD_DIR.tar.gz ${GITHUB_WORKSPACE}/openwrt/bin/targets/mvebu/cortexa9/
cd ${GITHUB_WORKSPACE}/openwrt
}
#         rm -rf bin/targets/mvebu/cortexa9/kmods
#         cd ${GITHUB_WORKSPACE}/openwrt


#          echo 'src/gz purefusion_kmods https://raw.githubusercontent.com/DevOpenWRT-Router/Linksys_OpenWRT_Releases/main/kmods/$KMOD_DIR' >> openwrt/package/system/opkg/files/customfeeds.conf



$1
exit 0
