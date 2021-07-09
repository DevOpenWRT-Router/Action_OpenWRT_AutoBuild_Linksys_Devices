#!/bin/bash
#
# Copyright (c) 2021 By Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/coolsnowwolf/lede
# File name: lean_packages.sh
# Description: OpenWRT Packages by coolsnowwolf (Before Update feeds)
#
# Updated By Eliminater74
################################################################################

echo "Downloading coolsnowwolf's lean packages"

svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/UnblockNeteaseMusic package/lean/UnblockNeteaseMusic
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/UnblockNeteaseMusicGo package/lean/UnblockNeteaseMusicGo
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/adbyby package/lean/adbyby
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/amule package/lean/amule
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/antileech package/lean/antileech
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/autocore package/lean/autocore
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/automount package/lean/automount
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/autosamba package/lean/autosamba
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/baidupcs-web package/lean/baidupcs-web
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/csstidy package/lean/csstidy
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ddns-scripts_aliyun package/lean/ddns-scripts_aliyun
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ddns-scripts_dnspod package/lean/ddns-scripts_dnspod
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/default-settings package/lean/default-settings
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/dns2socks package/lean/dns2socks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/dnsforwarder package/lean/dnsforwarder
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/dnsproxy package/lean/dnsproxy
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/dsmboot package/lean/dsmboot
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/frp package/lean/frp
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/gmediarender package/lean/gmediarender
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ipt2socks package/lean/ipt2socks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ipv6-helper package/lean/ipv6-helper
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/k3-brcmfmac4366c-firmware package/lean/k3-brcmfmac4366c-firmware
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/k3screenctrl package/lean/k3screenctrl
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/libcryptopp package/lean/libcryptopp
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-accesscontrol package/lean/luci-app-accesscontrol
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-adbyby-plus package/lean/luci-app-adbyby-plus
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-airplay2 package/lean/luci-app-airplay2
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-amule package/lean/luci-app-amule
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-autoreboot package/lean/luci-app-autoreboot
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-baidupcs-web package/lean/luci-app-baidupcs-web
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-cifs-mount package/lean/luci-app-cifs-mount
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-cifsd package/lean/luci-app-cifsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-cpufreq package/lean/luci-app-cpufreq
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-diskman package/lean/luci-app-diskman
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-dnsfilter package/lean/luci-app-dnsfilter
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-dnsforwarder package/lean/luci-app-dnsforwarder
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-docker package/lean/luci-app-docker
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-easymesh package/lean/luci-app-easymesh
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-familycloud package/lean/luci-app-familycloud
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-filetransfer package/lean/luci-app-filetransfer
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-frpc package/lean/luci-app-frpc
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-frps package/lean/luci-app-frps
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-guest-wifi package/lean/luci-app-guest-wifi
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-haproxy-tcp package/lean/luci-app-haproxy-tcp
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ipsec-vpnd package/lean/luci-app-ipsec-vpnd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-jd-dailybonus package/lean/luci-app-jd-dailybonus
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-kodexplorer package/lean/luci-app-kodexplorer
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-music-remote-center package/lean/luci-app-music-remote-center
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-mwan3helper package/lean/luci-app-mwan3helper
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-n2n_v2 package/lean/luci-app-n2n_v2
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-netdata package/lean/luci-app-netdata
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-nfs package/lean/luci-app-nfs
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-nft-qos package/lean/luci-app-nft-qos
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-nps package/lean/luci-app-nps
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-openvpn-server package/lean/luci-app-openvpn-server
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-pppoe-relay package/lean/luci-app-pppoe-relay
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ps3netsrv package/lean/luci-app-ps3netsrv
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-qbittorrent package/lean/luci-app-qbittorrent
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ramfree package/lean/luci-app-ramfree
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-rclone package/lean/luci-app-rclone
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-samba4 package/lean/luci-app-samba4
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-softethervpn package/lean/luci-app-softethervpn
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ssrserver-python package/lean/luci-app-ssrserver-python
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-syncdial package/lean/luci-app-syncdial
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ttyd package/lean/luci-app-ttyd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-turboacc package/lean/luci-app-turboacc
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-unblockmusic package/lean/luci-app-unblockmusic
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-usb-printer package/lean/luci-app-usb-printer
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-uugamebooster package/lean/luci-app-uugamebooster
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-v2ray-server package/lean/luci-app-v2ray-server
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-verysync package/lean/luci-app-verysync
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd package/lean/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vsftpd package/lean/luci-app-vsftpd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-webadmin package/lean/luci-app-webadmin
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-wrtbwmon package/lean/luci-app-wrtbwmon
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-xlnetacc package/lean/luci-app-xlnetacc
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-zerotier package/lean/luci-app-zerotier
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-lib-docker package/lean/luci-lib-docker
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-lib-fs package/lean/luci-lib-fs
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-proto-bonding package/lean/luci-proto-bonding
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-theme-argon package/lean/luci-theme-argon
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-theme-netgear package/lean/luci-theme-netgear
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/microsocks package/lean/microsocks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/mt package/lean/mt
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/n2n_v2 package/lean/n2n_v2
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/npc package/lean/npc
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ntfs3-mount package/lean/ntfs3-mount
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ntfs3 package/lean/ntfs3
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/openwrt-fullconenat package/lean/openwrt-fullconenat
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/pdnsd-alt package/lean/pdnsd-alt
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/polarssl package/lean/polarssl
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ps3netsrv package/lean/ps3netsrv
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/qBittorrent-static package/lean/qBittorrent-static
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/qBittorrent package/lean/qBittorrent
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/qtbase package/lean/qtbase
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/qttools package/lean/qttools
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/r8125 package/lean/r8125
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/r8152 package/lean/r8152
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/r8168 package/lean/r8168
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/rblibtorrent package/lean/rblibtorrent
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/rclone-ng package/lean/rclone-ng
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/rclone-webui-react package/lean/rclone-webui-react
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/rclone package/lean/rclone
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2 package/lean/redsocks2
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/lean/shortcut-fe
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/simple-obfs package/lean/simple-obfs
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/srelay package/lean/srelay
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/tcpping package/lean/tcpping
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/trojan package/lean/trojan
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/uugamebooster package/lean/uugamebooster
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/verysync package/lean/verysync
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd package/lean/vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vsftpd-alt package/lean/vsftpd-alt
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/wol package/lean/wol
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/wxbase package/lean/wxbase
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
exit 0
