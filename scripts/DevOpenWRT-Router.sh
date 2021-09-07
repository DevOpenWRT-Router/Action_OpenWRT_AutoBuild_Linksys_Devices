#!/bin/bash
#
# Copyright (c) 2021 By Eliminater74
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/DevOpenWRT-Router?type=source
# File name: DevOpenWRT-Router.sh
# Description: OpenWRT Packages by Eliminater74
#
# Updated By Eliminater74
################################################################################

### luci-app-log
git clone https://github.com/DevOpenWRT-Router/luci-app-log.git package/luci-app-log
### luci-app-tn-logview
git clone https://github.com/DevOpenWRT-Router/luci-app-tn-logview.git package/luci-app-tn-logview
### syslog_fc
git clone https://github.com/DevOpenWRT-Router/syslog_fc.git package/syslog_fc

### luci-app-interfaces-statistics
git clone https://github.com/DevOpenWRT-Router/luci-app-interfaces-statistics.git package/luci-app-interfaces-statistics
### luci-app-cpu-status
git clone https://github.com/DevOpenWRT-Router/luci-app-cpu-status.git package/luci-app-cpu-status
### luci-app-temp-status
git clone https://github.com/DevOpenWRT-Router/luci-app-temp-status.git package/luci-app-temp-status
### luci-app-rebootschedule
git clone https://github.com/DevOpenWRT-Router/luci-app-rebootschedule.git package/luci-app-rebootschedule
### luci-app-timecontrol
git clone https://github.com/DevOpenWRT-Router/luci-app-timecontrol.git package/luci-app-timecontrol
### luci-app-cpulimit
git clone https://github.com/DevOpenWRT-Router/luci-app-cpulimit.git package/luci-app-cpulimit
### luci-app-mqos
git clone https://github.com/DevOpenWRT-Router/luci-app-mqos.git package/luci-app-mqos
### luci-app-disks-info
git clone https://github.com/DevOpenWRT-Router/luci-app-disks-info.git package/luci-app-disks-info
### NetSpeedTest
git clone https://github.com/DevOpenWRT-Router/netspeedtest.git package/NetSpeedTest
### luci-app-netdata A
git clone https://github.com/DevOpenWRT-Router/luci-app-netdata-A.git package/luci-app-netdata
### luci-app-netdata B
## git clone https://github.com/DevOpenWRT-Router/luci-app-netdata-B.git package/luci-app-netdata
### luci-app-observatory
git clone https://github.com/DevOpenWRT-Router/luci-app-observatory.git package/luci-app-observatory
### luci-app-rtorrent-js
git clone https://github.com/DevOpenWRT-Router/luci-app-rtorrent-js.git package/luci-app-rtorrent-js
### luci-app-autowms
git clone https://github.com/DevOpenWRT-Router/luci-app-autowms.git package/luci-app-autowms
### luci-default-settings
git clone https://github.com/DevOpenWRT-Router/luci-default-settings.git package/luci-default-settings

### luci-app-tn-ttyd DO NOT USE
# git clone https://github.com/DevOpenWRT-Router/luci-app-tn-ttyd.git package/luci-app-tn-ttyd
### luci-app-tn-shellinabox
# git clone https://github.com/DevOpenWRT-Router/luci-app-tn-shellinabox.git package/luci-app-tn-shellinabox
### luci-app-tn-watchdog
# git clone https://github.com/DevOpenWRT-Router/luci-app-tn-watchdog.git package/luci-app-tn-watchdog
### luci-app-tn-netports
# git clone https://github.com/DevOpenWRT-Router/luci-app-tn-netports.git package/luci-app-tn-netports

echo "End of DevOpenWRT-Router.sh"
exit 0
