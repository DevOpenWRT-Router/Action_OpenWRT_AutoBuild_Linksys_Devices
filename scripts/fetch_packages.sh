#!/bin/bash
#
# Copyright (c) 2022 By Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# File name: fetch_packages.sh
# Description: OpenWRT Packages
#
# Updated By Eliminater74
################################################################################

### -------------------------------------------------------------------------------------------------------------- ###
echo " Fetching All Personal Repo's"

PERSONAL_PACKAGES() {
echo "Fetching From DevOpenWRT-Router:"

### luci-app-mqos
git clone https://github.com/DevOpenWRT-Router/luci-app-mqos.git package/PureFusionWRT/luci-app-mqos
### luci-default-settings
git clone https://github.com/DevOpenWRT-Router/luci-default-settings.git package/PureFusionWRT/luci-default-settings
### my-default-settings (LUCI)
git clone https://github.com/DevOpenWRT-Router/my-default-settings.git package/PureFusionWRT/my-default-settings
### luci-app-ota
git clone https://github.com/DevOpenWRT-Router/luci-app-ota.git package/PureFusionWRT/luci-app-ota

echo "END Fetching From DevOpenWRT-Router:"
}

UNSORTED_GIT_PACKAGES(){
  echo "Fetching UN-Sorted GIT Packages:"
  
  ### luci-app-access
  git clone https://github.com/resmh/luci-app-access.git package/luci-app-access

  ### luci-app-webguide
  git clone https://github.com/p1ay8y3ar/luci-app-webguide.git package/p1ay8y3ar/luci-app-webguide

  ### autocore-arm-x86
  #git clone https://github.com/MatJeheyy/autocore-arm-x86.git package/MatJeheyy/autocore
  #rm -rf package//MatJeheyy/autocore/po
}


UNSORTED_PACKAGES() {
echo "Fetching From unSorted Repo's:"

### luci-app-diskman
## A Simple Disk Manager for LuCI, support disk partition and format, support raid / btrfs-raid / btrfs-snapshot
mkdir -p package/luci-app-diskman
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile -O package/luci-app-diskman/Makefile
mkdir -p package/parted
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile

echo "END Fetching From unSorted Repo's:"
}

echo "End of Fetching All Personal Repos"

SBWM1_PACKAGES() {
  ### autocore-arm
  git clone https://github.com/sbwml/autocore-arm.git package/sbwml/autocore-arm
  ### openwrt-qBittorrent-Enhanced-Edition
  git clone https://github.com/sbwml/openwrt-qBittorrent-Enhanced-Edition.git package/sbwml/openwrt-qBittorrent-Enhanced-Edition
  ### openwrt-qBittorrent
  git clone https://github.com/sbwml/openwrt-qBittorrent.git package/sbwml/openwrt-qBittorrent
  ### openwrt-filebrowser
  git clone https://github.com/sbwml/openwrt-filebrowser.git package/sbwml/openwrt-filebrowser
  ### OpenAppFilter
  git clone https://github.com/sbwml/OpenAppFilter.git package/sbwml/OpenAppFilter
  ### openwrt-alist
  git clone https://github.com/sbwml/openwrt-alist.git package/sbwml/openwrt-alist

  echo "END Fetching From sbwml's Repos:"
}

GSPOTX2F_PACKAGES() {
  ### package/luci-app-cpu-status
  git clone https://github.com/gSpotx2f/luci-app-cpu-status.git package/gSpotx2f/luci-app-cpu-status
  rm -rf package/gSpotx2f/luci-app-cpu-status/po

  ### luci-app-cpu-perf
  git clone https://github.com/gSpotx2f/luci-app-cpu-perf.git package/gSpotx2f/luci-app-cpu-perf
  rm -rf package/gSpotx2f/luci-app-cpu-perf/po

  ### luci-app-interfaces-statistics
  git clone https://github.com/gSpotx2f/luci-app-interfaces-statistics.git package/gSpotx2f/luci-app-interfaces-statistics
  rm -rf package/gSpotx2f/luci-app-interfaces-statistics/po

  ### luci-app-internet-detector
  git clone https://github.com/gSpotx2f/luci-app-internet-detector.git package/gSpotx2f/luci-app-internet-detector
  rm -rf package/gSpotx2f/luci-app-internet-detector/po

  ### luci-app-log
  git clone https://github.com/gSpotx2f/luci-app-log.git package/gSpotx2f/luci-app-log
  rm -rf package/gSpotx2f/luci-app-log/po

  ### luci-app-temp-status
  git clone https://github.com/gSpotx2f/luci-app-temp-status.git package/gSpotx2f/luci-app-temp-status
  rm -rf package/gSpotx2f/luci-app-temp-status/po
  
  ### luci-app-disks-info
  git clone https://github.com/gSpotx2f/luci-app-disks-info.git package/gSpotx2f/luci-app-disks-info
  rm -rf package/gSpotx2f/luci-app-disks-info/po

  echo "END Fetching From gSpotx2f's Repos:"
}

LINKEASE_PACKAGES() {
  ### istore-packages
  git clone https://github.com/linkease/istore-packages.git package/linkease/istore-packages
}

KENZOK8_PACKAGES() {
echo "Downloading Kenzok8's small-packages"

git clone https://github.com/kenzok8/small-package.git package/kenzok8

rm -rf package/kenzok8/my-default-settings # using a dif
rm -rf package/kenzok8/my-autocore # Using the one above in unsorted
rm -rf package/kenzok8/luci-app-easyupdate
rm -rf package/kenzok8/mosdns # Build Errors
rm -rf package/kenzok8/luci-app-mosdns
rm -rf package/kenzok8/luci-app-smartdns
rm -rf package/kenzok8/smartdns
#rm -rf package/kenzok8/luci-app-netspeedtest
rm -rf package/kenzok8/v2ray-core
rm -rf package/kenzok8/v2ray-geodata
rm -rf package/kenzok8/v2ray-plugin
rm -rf package/kenzok8/v2raya
rm -rf package/kenzok8/.github
rm -rf package/kenzok8/main.sh
rm -rf package/kenzok8/LICENSE
rm -rf package/kenzok8/README.md

}

SUNDAQIANG_PACKAGES() {
  echo "Downloading sundaqiang's packages"

  git clone https://github.com/sundaqiang/openwrt-packages.git package/sundaqiang
}

O-BUG_PACKAGES() {
  echo "Downloading o-bug's packages"

  git clone https://github.com/o-bug/openwrt-packages.git package/o-bug
}
### -------------------------------------------------------------------------------------------------------------- ###
LEAN_PACKAGES() {
echo "Downloading coolsnowwolf's lean packages"

i=0
len=0
unset packages
unset url
unset placement
url="https://github.com/coolsnowwolf/lede/trunk/package/lean"
placement="package/lean"

while read -r line
do
    packages[ $i ]="$line"
    if [[ ${line} != *"/" ]];then
      echo "$line Doesnt Contain /"; continue
      elif [[ ${line} == "doc" ]];then
      echo "$line Contains doc"
      fi
    (( i++ ))
done < <(svn list $url)

## get length of $packages array
len=${#packages[@]}
echo "$len Packages"

## Use bash for loop
for (( i=0; i<len; i++ ))
do
  echo "${packages[$i]}"
  svn co $url/"${packages[$i]}" $placement/"${packages[$i]}"
  
done

rm -rf package/lean/autocore
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
}

### -------------------------------------------------------------------------------------------------------------- ###
SIRPDBOY_PACKAGES() {
echo "Downloading sirpdboy's packages"

## Sirpdboy's luci-app-netdata
git clone https://github.com/sirpdboy/luci-app-netdata.git package/sirpdboy/luci-app-netdata
## Sirpdboy's myautocore enhanced version preview information only for OPENWRT
svn co https://github.com/sirpdboy/myautocore/trunk/myautocore package/sirpdboy/myautocore

git clone https://github.com/sirpdboy/sirpdboy-package.git package/sirpdboy_A

rm -rf package/sirpdboy_A/adguardhome
rm -rf package/sirpdboy_A/doc
rm -rf package/sirpdboy_A/luci-app-access-control ## NEEDS FIXED
rm -rf package/sirpdboy_A/luci-app-baidupcs-web
rm -rf package/sirpdboy_A/luci-app-chinadns-ng
rm -rf package/sirpdboy_A/luci-app-cpulimit
rm -rf package/sirpdboy_A/luci-app-dockerman
rm -rf package/sirpdboy_A/luci-app-easymesh
rm -rf package/sirpdboy_A/luci-app-netdata
rm -rf package/sirpdboy_A/luci-app-netspeedtest
rm -rf package/sirpdboy_A/luci-app-onliner
rm -rf package/sirpdboy_A/luci-app-ramfree
rm -rf package/sirpdboy_A/luci-app-rebootschedule
rm -rf package/sirpdboy_A/luci-app-smartdns
rm -rf package/sirpdboy_A/luci-app-socat
rm -rf package/sirpdboy_A/luci-app-timecontrol
rm -rf package/sirpdboy_A/luci-app-wrtbwmon
rm -rf package/sirpdboy_A/luci-theme-argon_new
rm -rf package/sirpdboy_A/luci-theme-atmaterial
rm -rf package/sirpdboy_A/luci-theme-btmod
rm -rf package/sirpdboy_A/luci-theme-edge
rm -rf package/sirpdboy_A/luci-theme-ifit
rm -rf package/sirpdboy_A/luci-theme-opentomato
rm -rf package/sirpdboy_A/luci-theme-opentomcat
rm -rf package/sirpdboy_A/luci-theme-opentopd
rm -rf package/sirpdboy_A/netdata
rm -rf package/sirpdboy_A/speedtest-cli ## NEEDS FIXED
rm -rf package/sirpdboy_A/smartdns ## NEEDS FIXED

echo "END of sirpdboy's packages"

echo "From sirpdboy's BUILD packages"

git clone https://github.com/sirpdboy/build.git package/sirpdboy_B

#rm -rf  package/sirpdboy_B/autocore
rm -rf package/sirpdboy_B/automount
rm -rf package/sirpdboy_B/autosamba-samba4
rm -rf package/sirpdboy_B/default-settings # using a dif
rm -rf package/sirpdboy_B/doc # not a package
rm -rf package/sirpdboy_B/gcc # not a package
rm -rf package/sirpdboy_B/ksmbd-tools
rm -rf package/sirpdboy_B/luci-app-ksmbd
rm -rf package/sirpdboy_B/luci-app-samba
rm -rf package/sirpdboy_B/luci-app-samba4
rm -rf package/sirpdboy_B/miniupnpd
rm -rf package/sirpdboy_B/mwan3
rm -rf package/sirpdboy_B/samba36
rm -rf package/sirpdboy_B/samba4
rm -rf package/sirpdboy_B/my-autocore
rm -rf package/sirpdboy_B/autocore
rm -rf package/sirpdboy_B/mycore
rm -rf package/sirpdboy_B/pass
rm -rf package/sirpdboy_B/set # Not a package
rm -rf package/sirpdboy_B/socat

echo "END of sirpdboy's Build packages"
}

### -------------------------------------------------------------------------------------------------------------- ###
HELMIAU_PACKAGES() {
echo "Downloading helmiau's packages"

git clone https://github.com/helmiau/helmiwrt-packages.git package/helmiau

rm -rf package/helmiau/badvpn
rm -rf package/helmiau/build-ipk
rm -rf package/helmiau/corkscrew
rm -rf package/helmiau/preview

echo "END of helmiau's Build packages"
}

### -------------------------------------------------------------------------------------------------------------- ###
NUEXINI_PACKAGES() {
echo "Downloading NueXini's packages"

git clone https://github.com/NueXini/NueXini_Packages.git package/NueXini

rm -rf package/NueXini/autocore
rm -rf package/NueXini/mosdns
rm -rf package/NueXini/luci-app-mosdns

echo "END of NueXini's Build packages"
}

LUCI_THEMES() {
  echo "Fetching LUCI-Themes"
  ### THEMES ###
  ### new argon theme
  # git clone -b master https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
  ### New argon theme control program
  # git clone -b master https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
  ### luci-theme-opentomcat
  # git clone https://github.com/chaoxiaozhu/luci-theme-opentomcat.git package/luci-theme-opentomcat
  ### luci-theme-rosy
  # git clone https://github.com/rosywrt/luci-theme-rosy.git package/luci-theme-rosy
  ### luci-theme-netgear
  # git clone https://github.com/ysoyipek/luci-theme-netgear.git package/luci-theme-netgear
  ### luci-theme-edge2 ###
  # git clone -b main https://github.com/YL2209/luci-theme-edge2.git package/luci-theme-edge2
  ### luci-theme-opentopd thme openwrt theme
  # git clone https://github.com/sirpdboy/luci-theme-opentopd.git package/luci-theme-opentopd
  ### btmod theme
  # git clone https://github.com/sirpdboy/luci-theme-btmod.git package/luci-theme-btmob
  ### luci-theme-opentomcat
  # git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat
  ### luci-theme-netgear
  # git clone https://github.com/i028/luci-theme-netgear.git package/luci-theme-netgear
  ### luci-theme-ifit
  # git clone https://github.com/YL2209/luci-theme-ifit.git package/luci-theme-ifit
  ### luci-theme-surfboard
  # git clone https://github.com/SURFBOARD-ONE/luci-theme-surfboard.git package/luci-theme-surfboard
  ### luci-theme-atmaterial
  # git clone https://github.com/miccjing/luci-theme-atmaterial.git package/luci-theme-atmaterial
  ### luci-theme-mcat
  # git clone https://github.com/fszok/luci-theme-mcat.git package/luci-theme-mcat
  ### luci-theme-fate
  # git clone https://github.com/fatelpc/luci-theme-fate.git package/luci-theme-fate
  echo "Done Fetching LUCI-Themes"
}

DELETE_UNWANTED(){
  echo "Removing all found po2lmo from Package Makefiles"
  find  -iname "Makefile" -exec  sed -i '/po2lmo/d' {} \;
  echo "Removing all Directorys containing po"
  find . -name "po" | xargs rm -rf;
  echo "Removing all Directorys containing .svn"
  find . -name ".svn" | xargs rm -rf;
  echo "Removing all Directorys containing .git"
  find . -name ".git" | xargs rm -rf;


}

DELETE_DUPLICATES() {
  echo "Running rmlint:"
  rmlint --types "dd" --paranoid --honour-dir-layout --merge-directories --max-depth=4 "$GITHUB_WORKSPACE"/openwrt/package
  ./rmlint.sh -c -q -d
  rm -rf rmlint.json
}

### -------------------------------------------------------------------------------------------------------------- ###

LUCI_THEMES;
PERSONAL_PACKAGES;
UNSORTED_GIT_PACKAGES;
UNSORTED_PACKAGES;
SBWM1_PACKAGES;
GSPOTX2F_PACKAGES;
LINKEASE_PACKAGES;
KENZOK8_PACKAGES;
SUNDAQIANG_PACKAGES;
LEAN_PACKAGES;
SIRPDBOY_PACKAGES;
HELMIAU_PACKAGES;
NUEXINI_PACKAGES;
O-BUG_PACKAGES;
DELETE_UNWANTED;
DELETE_DUPLICATES;
### -------------------------------------------------------------------------------------------------------------- ###

exit 0
