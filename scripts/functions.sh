#!/bin/bash
# shellcheck source=/dev/null
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
echo "Loading Functions into Memory.."

### My lame ass attempt to setup error catching
## BOOTSTRAP ##
BOOTSTRAP_START() {
source scripts/lib/oo-bootstrap.sh
import util/log util/exception util/tryCatch util/namedParameters util/class
}

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
sed -i "s/root::0:0:99999:7:::/root:$1$ScQIGKsX$q0qEf\/tAQ2wpTR6zIUIjo.:0:0:99999:7:::/g" package/base-files/files/etc/shadow
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
### Some usefull command build tools ###
function git_sparse_clone() (
          branch="$1" rurl="$2" localdir="$3" && shift 3
          git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$rurl" "$localdir"
          cd "$localdir" || exit
          git sparse-checkout init --cone
          git sparse-checkout set $@
          mv -n $@ ../
          cd ..
          rm -rf "$localdir"
        )

function git_clone() (
          git clone --depth 1 "$1" "$2" || true
        )

function mvdir() {
          mv -n $(find $1/* -maxdepth 0 -type d) ./
          rm -rf "$1"
        }

function latest() {
          (curl -gs -H 'Content-Type: application/json' \
             -H "Authorization: Bearer ${{ secrets.REPO_TOKEN }}" \
             -X POST -d '{ "query": "query {repository(owner: \"'"$1"'\", name: \"'"$2"'\"){refs(refPrefix:\"refs/tags/\",last:1,orderBy:{field:TAG_COMMIT_DATE,direction:ASC}){edges{node{name target{commitUrl}}}}defaultBranchRef{target{...on Commit {oid}}}}}"}' https://api.github.com/graphql)
        }
### ------------------------------------------------------------------------------------------------------- ###
CLONE_OPENWRT_SOURCE() {
    echo "Cloning Source/Branch"

    df -hT "$PWD"

    URL=https://github.com/openwrt/openwrt.git
    BRANCH=master
    git_clone "$URL" "$BRANCH" openwrt
    ln -sf /workdir/openwrt "$GITHUB_WORKSPACE"/openwrt
    return
}

SET_LUCI_SOURCE() {
    echo "Setting LUCI souce to feed from."
    sed -i 's#/git.openwrt.org/project/luci.git#/git.openwrt.org/project/luci.git#g' feeds.conf.default
    sed -i 's#/github.com/coolsnowwolf/luci#/git.openwrt.org/project/luci.git#g' feeds.conf.default
}

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

### This is NEEDED to setup all pre-configs before building
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

### This will setup ccache support
### CCACHE SETUP ###
CCACHE_SETUP() {
echo "Seeding .config (enable ccache):"
printf 'CONFIG_CCACHE=y\n' >> .config
echo "Setting ccache directory:"
export CCACHE_DIR="$GITHUB_WORKSPACE"/openwrt/.ccache
echo "Fix Sloppiness of ccache:"
ccache --set-config=sloppiness=file_macro,locale,time_macros
ccache -s
}

### Not even sure why I still have this here, I dont really use it
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

### This is a quick way to apply correct chmod to all files and directorys needed
SMART_CHMOD() {
  MY_Filter=$(mktemp)
  echo '/\.git' >  "${MY_Filter}"
  echo '/\.svn' >> "${MY_Filter}"
  find ./ -maxdepth 1 | grep -v '\./$' | grep -v '/\.git' | xargs -s1024 chmod -R u=rwX,og=rX
  find ./ -type f | grep -v -f "${MY_Filter}" | xargs -s1024 file | grep 'executable\|ELF' | cut -d ':' -f1 | xargs -s1024 chmod 755
  rm -f "${MY_Filter}"
  unset MY_Filter
}

### CHMOD -R +x everything in files
FILES_CHMOD() {
  if [ -e "$GITHUB_WORKSPACE"/configs/files ] ; then
    echo "Preparing files"
    mv "$GITHUB_WORKSPACE"/configs/files "$GITHUB_WORKSPACE"/openwrt/files
    echo "Removing all Files containing EMPTY"
    find  "$GITHUB_WORKSPACE"/openwrt/files -name "EMPTY" | xargs rm -rf;
    echo "chmod -R +x files"
    chmod -R +x "$GITHUB_WORKSPACE"/openwrt/files/bin
    chmod -R +x "$GITHUB_WORKSPACE"/openwrt/files/sbin
    chmod -R +x "$GITHUB_WORKSPACE"/openwrt/files/etc/profile.d
    chmod -R +x "$GITHUB_WORKSPACE"/openwrt/files/etc/rc.d
    chmod -R +x "$GITHUB_WORKSPACE"/openwrt/files/etc/init.d
    chmod -R +x "$GITHUB_WORKSPACE"/openwrt/files/usr/share
    echo "Finished preparing files"
  else
    echo "No ($GITHUB_WORKSPACE/configs/files) Found"
  fi
}

FILES_OpenWrtScripts() {
  echo "Downloading richb-hanover/OpenWrtScripts to files/sbin/OpenWrtScripts."
  svn export https://github.com/richb-hanover/OpenWrtScripts/trunk files/usr/lib/OpenWrtScripts
  echo "Moving: autoSQM.sh"
  mv "$GITHUB_WORKSPACE"/configs/DATA/autoSQM.sh "$GITHUB_WORKSPACE"/openwrt/files/usr/lib/OpenWrtScripts
  echo "Moving: median.awk"
  mv "$GITHUB_WORKSPACE"/configs/DATA/median.awk "$GITHUB_WORKSPACE"/openwrt/files/usr/lib/OpenWrtScripts
}

### Apply all patches that are in 'patch' directory
APPLY_PATCHES() {
  mv "$GITHUB_WORKSPACE"/configs/patches "$GITHUB_WORKSPACE"/openwrt/patches
  cd "$GITHUB_WORKSPACE"/openwrt || exit
  git am patches/*.patch
  if [ $? = 0 ] ; then
    echo "[*] 'git am patches/*.patch' Ran successfully."
  else
    echo "[*] 'git am patches/*.patch' FAILED."
  fi
  rm -rf patches

}

### When finished, this will auto download Pull Request Patches from openwrt and apply them
APPLY_PR_PATCHES() {
  echo "This is WORKING Here:"
  file="$GITHUB_WORKSPACE"/scripts/data/PR_patches.txt
  while read -r line; do
  cd "$GITHUB_WORKSPACE"/openwrt && wget https://patch-diff.githubusercontent.com/raw/openwrt/openwrt/pull/"$line".patch
  echo "Applying $line.patch"
  git am "$line".patch
  if [ $? = 0 ] ; then
    echo "[*] 'git am $line.patch' Ran successfully."
  else
    echo "[*] 'git am $line.patch' FAILED."
  fi
  done < "$file"
}

RESET_COMMIT() {
  echo "Reseting HEAD to $1, T:$0, T1:$1, T2:$2"
  git reset --hard "$1"
  if [ $? = 0 ] ; then
    echo "[*] 'git reset --hard $1 Ran successfully."
  else
    echo "[*] git reset --hard $1 FAILED."
  fi
}

CHANGE_DEFAULT_BANNER() {
  if [ -f "$GITHUB_WORKSPACE/openwrt/package/base_files/files/etc/banner" ];
  then 
  rm -rf "$GITHUB_WORKSPACE"/openwrt/package/base_files/files/etc/banner
  cp configs/DATA/banner "$GITHUB_WORKSPACE"/openwrt/package/base_files/files/etc/
  fi
}

### Dont use this Fuction Wildly, Will cause many building Issues
REMOVE_PO2LMO() {
  echo "Removing all found po2lmo from Package Makefiles"
  find ./package -iname "Makefile" -exec  sed -i '/po2lmo/d' {} \;
}

### Be careful when using this one, Can resort to build Failing
REMOVE_PO() {
  echo "Removing all Directorys containing po"
  find ./package -name "po" | xargs rm -rf;
}

REMOVE_LANGUAGES() {
  echo "Removing All Languages except English"
  #find ./feeds/luci/modules/luci-base/po/ ! -name 'en' -type d -exec rm -rf {} +
  find ./package -name "po" | xargs rm -rf;
  find ./feeds -name "po" | xargs rm -rf;
}

### This should 100% safe to use
REMOVE_SVN() {
  echo "Removing all Directorys containing .svn"
  find ./package -name ".svn" | xargs rm -rf;
}

### Make sure you only run this in package Directory, else all could fail
REMOVE_GIT() {
  echo "Removing all Directorys containing .git"
  find ./package -name ".git" | xargs rm -rf;
}

### Still testing this out, Not sure if it benifits or causes issues
DELETE_DUPLICATES() {
  echo "Running rmlint:"
  rmlint --types "dd" --paranoid --honour-dir-layout --merge-directories --max-depth=2 "$GITHUB_WORKSPACE"/openwrt/package || rmlint --types "dd" --paranoid --honour-dir-layout --merge-directories --max-depth=4 package
  find . -name "rmlint.sh" | xargs rmlint.sh -c -q -d || ./rmlint.sh -c -q -d
  find . -name "rmlint.json" | xargs rm -rf
}

### This is used for file and archive naming reasons, Plus checks for wrtmulti config used
get_deviceID() {
if [ "$HARDWARE_DEVICE" != "wrtmulti" ]; then
  grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
  [ -s DEVICE_NAME ] && echo "DEVICE_NAME=_$(cat DEVICE_NAME)" >> "$GITHUB_ENV"
else echo "linksys_wrtmulti" > DEVICE_NAME
     [ -s DEVICE_NAME ] && echo "DEVICE_NAME=_$(cat DEVICE_NAME)" >> "$GITHUB_ENV"
fi
  echo "FILE_DATE=_$(date +"%Y%m%d%H%M")" >> "$GITHUB_ENV"
}

### This is needed for creation of kmods directory
kernel_version() {
cd openwrt || return
find build_dir/ -name .vermagic -exec cat {} \; >VERMAGIC  # Find hash
find build_dir/ -name "linux-5.*.*" -type d >KERNELVERSION # find kernel version
kv=$(tail -n +2 KERNELVERSION | sed 's/.*x-//')
vm=$(head -n 1 VERMAGIC)                                # read kernel hash from file                                     # Get last 7 chars from kernel version
rm -rf VERMAGIC KERNELVERSION                              # remove both files, Not needed anymore
cd bin/targets/*/* || return
echo "TARGET_DIR=$PWD" >>"$GITHUB_ENV"
# TARGET_DIR=$PWD
KERNEL_VER=$kv"-"$vm                      # add together to complete
KMOD_DIR=$kv"-"$vm                        # add together to complete
echo "KERNEL_VER=$kv"-"$vm" >>"$GITHUB_ENV" # store in get actions
echo "KMOD_DIR=$kv"-"$vm" >>"$GITHUB_ENV"   # store in get actions
echo "------------------------------------------------"
echo "Kernel: $KERNEL_VER" # testing
echo "DIR: $KMOD_DIR"
echo "------------------------------------------------"
echo "$KMOD_DIR" >> "$GITHUB_WORKSPACE"/openwrt/kmod
cat "$GITHUB_WORKSPACE"/openwrt/kmod
}

### This is really 2nd part of above kernel version
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

CREATE_KMODS() {
  set -x

  #STAGING_DIR_HOST="$(make --no-print-directory -C target/linux val.STAGING_DIR_HOST)"

  export TOPDIR="$PWD"
  export STAGING_DIR_HOST="$(make --no-print-directory -C target/linux val.STAGING_DIR_HOST)"
  export MKHASH="$STAGING_DIR_HOST/bin/mkhash"
  export PATH="$STAGING_DIR_HOST/bin":"$PATH"

  BIN_DIR="$(make --no-print-directory -C target/linux val.BIN_DIR)"
  KEY_BUILD="$(make --no-print-directory -C target/linux val.BUILD_KEY)"
  KMOD_DIR="$(make --no-print-directory -C target/linux val.LINUX_VERSION val.LINUX_RELEASE val.LINUX_VERMAGIC | tr '\n' '-' | head -c -1)"

  pushd "$BIN_DIR" || exit
  rm -rf "kmods/$KMOD_DIR"
  mkdir -p "kmods/$KMOD_DIR"

  cp -fpR "packages"/automount* "kmods/$KMOD_DIR"/
  for i in "packages"/kmod-*; do cp -fpR "$i" "kmods/$KMOD_DIR"/; done
  popd

  pushd "$BIN_DIR/kmods/$KMOD_DIR" || exit
  "$TOPDIR"/scripts/ipkg-make-index.sh . 2>&1 > "Packages.manifest"
  grep -vE "^(Maintainer|LicenseFiles|Source|SourceName|Require|SourceDateEpoch)" "Packages.manifest" > "Packages"
  case "$(((64 + "$(stat -L -c%s "Packages")") % 128))" in
	  110|111)
		    echo -e "\033[33mWARNING: Applying padding in Packages to workaround usign SHA-512 bug!\033[0m"
		    { echo ""; echo ""; } >> "Packages"
	  ;;
  esac
  gzip -9nc "Packages" > "Packages.gz"
  "$STAGING_DIR_HOST"/bin/usign -S -m "Packages" -s "$KEY_BUILD"
  popd
}
### ------------------------------------------------------------------------------------------------------- ###

#"$1";
echo "Functions are now loaded into Memory."
#exit 0 # <-- We dont want to exit fom souce command
