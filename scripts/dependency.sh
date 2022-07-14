#!/usr/bin/env bash
### ---------------------------------------------------------------------------------------------- ###
### #!/bin/bash ###
### ---------------------------------------------------------------------------------------------- ###

if [[ $OSTYPE != "linux-gnu" ]]; then
  printf "This Script Should Be Run On Ubuntu Runner.\n"
  exit 1
fi

# Make Sure The Environment Is Non-Interactive
export DEBIAN_FRONTEND=noninteractive

[ -f /etc/os-release ] && . /etc/os-release

echo "::group::Install Build Env Tool"
sudo -E apt-get clean
sudo -E apt-get -qq update
sudo -E apt-get -qq full-upgrade
mkdir -p ~/.bin

export PATH="${HOME}/.bin:${PATH}"

curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
echo "::endgroup::"

echo "::group::Installing Necessary Packages"
sudo -E apt-get -qq install build-essential asciidoc binutils bzip2 gawk 
sudo -E apt-get -qq install gettext git libncurses5-dev libz-dev patch unzip 
sudo -E apt-get -qq install zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex 
sudo -E apt-get -qq install uglifyjs git-core p7zip p7zip-full msmtp libssl-dev 
sudo -E apt-get -qq install texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev 
sudo -E apt-get -qq install autoconf automake libtool autopoint device-tree-compiler 
sudo -E apt-get -qq install g++-multilib antlr3 gperf wget curl swig rsync python2.7 
sudo -E apt-get -qq install gcc-multilib libreadline-dev ccache vim nano 
sudo -E apt-get -qq install python3 python3-pip python3-ply haveged lrzsz scons 
sudo -E apt-get -qq install ecj fastjar re2c xz-utils tar rmlint lsb-release wget 
sudo -E apt-get -qq install software-properties-common curl libstdc++6 git wget rsync aria2 
sudo -E apt-get -qq install ack bison cmake cpio help2man intltool libgmp3-dev libltdl-dev libmpc-dev 
sudo -E apt-get -qq install libmpfr-dev mkisofs ninja-build pkgconf python-docutils squashfs-tools upx-ucl 
sudo -E apt-get -qq install xxd btrfs-progs dosfstools uuid-runtime mount util-linux parted rename genisoimage
sudo -E apt-get -qq install libxml2-utils make zip patchelf minicom openjdk-8-jdk
[ ${UBUNTU_CODENAME} = "bionic" ] && sudo -E apt-get -qq install python-networkx
echo "::endgroup::"

# uboot v2016
echo "::group::Installing for uboot v2016"
sudo -E apt-get -qq install device-tree-compiler
echo "::endgroup::"

# kernel release-4.4
echo "::group::Installing for kernel release-4.4"
sudo -E apt-get -qq install liblz4-tool
sudo -E apt-get -qq install bison
echo "::endgroup::"

# recommended
echo "::group::Installing recommended packages"
sudo -E apt-get -qq install openssh-server vim
sudo -E apt-get -qq install qemu-user-static
sudo -E apt-get -qq install exfat-fuse exfat-utils p7zip-full tree
echo "::endgroup::"

# build git-2.18+
echo "::group::Installing for build git-2.18+"
sudo -E apt-get -qq install autoconf
sudo -E apt-get -qq install libcurl4-openssl-dev libssh-dev
echo "::endgroup::"

# build x86-x64 kernel
echo "::group::Installing for build x86-x64 kernel"
sudo -E apt-get -qq install pkg-config
sudo -E apt-get -qq install libelf-dev
echo "::endgroup::"

# build mtd-utils v2.0.2+
echo "::group::Installing for build mtd-utils v2.0.2+"
sudo -E apt-get -qq install libtool
echo "::endgroup::"

# virtualbox
echo "::group::Installing for virtualbox"
sudo -E apt-get -qq install libqt5core5a libqt5gui5 libqt5opengl5 \
	libqt5printsupport5 libqt5widgets5 libqt5x11extras5 libsdl1.2debian
  echo "::endgroup::"

# buildroot (rockchip)
echo "::group::Installing for buildroot (rockchip)"
sudo -E apt-get -qq install texinfo
sudo -E apt-get -qq install genext2fs
echo "::endgroup::"

# crosstool-ng
echo "::group::Installing for crosstool-ng"
sudo -E apt-get -qq install lzip help2man libtool libtool-bin
echo "::endgroup::"

# qemu
echo "::group::Installing for qemu"
sudo -E apt-get -qq install debootstrap
echo "::endgroup::"

# for allwinner
echo "::group::Installing for allwinner"
sudo -E apt-get -qq install u-boot-tools swig python-dev python3-dev
echo "::endgroup::"

# act-greq
echo "::group::Installing for act-greq"
sudo apt -qq install ack-grep
echo "::endgroup::"

# openwrt
echo "::group::Installing for openwrt"
sudo -E apt-get -qq install time gettext java-propose-classpath apt zstd
echo "::endgroup::"

# simg2img
echo "::group::Installing for simg2img"
[ ${UBUNTU_CODENAME} = "bionic" ] && sudo -E apt-get -qq install android-tools-fsutils
[ ${UBUNTU_CODENAME} = "focal" ] && sudo -E apt-get -qq install android-sdk-libsparse-utils
echo "::endgroup::"

# libreELEC
echo "::group::Installing for libreELEC"
sudo -E apt-get -qq install bc lzop xfonts-utils xfonts-utils xfonts-utils xsltproc libjson-perl
echo "::endgroup::"

# for openwrt armhf <-- libc6:i386 NO Longer Used
#sudo -E apt-get -qq install libc6:i386

# for wireguard
echo "::group::Installing for wireguard"
sudo -E apt-get -qq install libmnl-dev
echo "::endgroup::"

echo "::group::Symlink (GCC) Setup"
echo "Setting up symlinks for GCC"
[ -f /usr/bin/gcc-8 ] && for i in $(ls /usr/bin/*-8); do sudo -E ln -sf "$i" "${i%%-8*}"; done
[ -f /usr/bin/gcc-9 ] && for i in $(ls /usr/bin/*-9); do sudo -E ln -sf "$i" "${i%%-9*}"; done
[ -f /usr/bin/gcc-10 ] && for i in $(ls /usr/bin/*-10); do sudo -E ln -sf "$i" "${i%%-10*}"; done
[ -f /usr/bin/gcc-11 ] && for i in $(ls /usr/bin/*-11); do sudo -E ln -sf "$i" "${i%%-11*}"; done
[ -f /usr/bin/gcc-12 ] && for i in $(ls /usr/bin/*-12); do sudo -E ln -sf "$i" "${i%%-12*}"; done
echo "::endgroup::"

echo "::group::Running Some Final Settings"
echo "Some Final Settings added"
sudo -E apt-get clean -qq
sudo -E ln -sf /usr/include/asm-generic /usr/include/asm
sudo timedatectl set-timezone "$TZ"
sudo mkdir -p /workdir
sudo chown $USER:$GROUPS /workdir
echo "::endgroup::"

# Running GIT ENV
echo "::group::GIT: Setting up Action Bot Email and Name"
echo "Setting up GIT env"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global user.name "github-actions[bot]"
echo "::endgroup::"

exit 0
