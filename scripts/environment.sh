#!/bin/bash

#################################################
#                                               #
# Created By Eliminater74 (C) 12/28/2020        #
#                                               #
# Updated on: 00/00/0000                        #
#                                               #
#################################################



### Initialization environment

### OpenWrt Build System Setup

sudo -E apt-get -qq remove --purge azure-cli ghc zulu* hhvm llvm* firefox google* dotnet* powershell mysql* php* mssql-tools msodbcsql17 android*
sudo -E apt-get -qq update
sudo -E apt-get -qq full-upgrade
sudo -E apt-get -qq install build-essential asciidoc binutils bzip2 coreutils gawk gettext git libncurses5-dev libz-dev patch unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-8 gcc++-8 gcc-8-multilib g++-8-multilib p7zip p7zip-full msmtp libssl-dev texinfo libreadline-dev libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint ccache curl wget vim nano python python3 python-pip python3-pip python-ply python3-ply haveged lrzsz device-tree-compiler scons antlr3 gperf ecj fastjar re2c xz-utils tar
for i in $(ls /usr/bin/*-8); do sudo -E ln -sf $i ${i%%-8*}; done 
sudo -E ln -sf /usr/include/asm-generic /usr/include/asm
sudo -E apt-get -qq autoremove --purge
sudo -E apt-get -qq clean
sudo -E swapoff -a
sudo -E rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /etc/mysql /etc/php /usr/local/lib/android /opt/ghc /swapfile
sudo timedatectl set-timezone "$TZ"
sudo mkdir -p /workdir
sudo chown $USER:$GROUPS /workdir

exit 0
