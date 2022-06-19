#!/bin/sh
#
# sysinfo.sh dla OpenWRT AA Cezary Jackiewicz 2013
#
# https://github.com/Rafciq/openwrt/blob/master/misc/sysinfo.sh
# 
#	1.00	CJ	Pierwsza wersja kodu
#	1.01	RD	Drobna przebudowa
#	1.02	RD	Korekta b³êdu wy¶w. zajeto¶ci Flash-a, dodanie kolorów
#	1.03	RD	Dodanie nazwy routera, zmiana formatowania
#	1.04	RD	Kosmetyka, sugestie @mikhnal. Zmiana przetwarzania info. o wan.
#	1.05	RD	Zmiana algorytmu pobierania danych dla wan i lan
#	1.06	RD	Parametryzacja kolorów i pojawiania siê podkre¶leñ
#	1.07	RD	Modyfikacja zwi±zana z poprawnym wy¶wietlaniem interfejsu dla prot.3g
#	1.08	RD	Modyfikacja wy¶wietlania DNS-ów dla wan, dodanie uptime dla interfejsów
#	1.09	RD	Dodanie statusu "Down" dla wy³±czonego wifi, zmiana wy¶wietlania dla WLAN(sta)
#	1.10	RD	Korekta wy¶wietlania dla WLAN(sta)
#	1.11	RD	Korekta wy¶wietlania stanu pamiêci, sugestie @dopsz 
#	1.12	RD	Zmiana kolejno¶ci wy¶wietlania warto¶ci stanu pamiêci + kosmetyka 
#	1.13	RD	Dodanie info o dhcp w LAN, zmiana sposobu wy¶wietlania informacji o LAN
#	1.14	RD	Dodanie informacji o ostatnich 5 b³êdach
#	1.15	RD	Zmiana stderr
#	1.16	RD	Dodanie wy¶wietlania informacji o swap
#	1.17	RD	Zmiana wyliczania informacji o flash
#	1.18	RD	Zmiana wy¶wietlania informacji o flash
#	1.19	RD	Zmiana wy¶wietlania informacji o sprzêcie
#	1.20	RD	Zmiana wy¶wietlania informacji o sprzêcie
#	1.21	RD	Dopasowyanie szeroko¶ci do zawarto¶ci /etc/banner
#	1.22	RD	Dodanie wyœwietlania w HTML-u
#
# Destination /sbin/sysinfo.sh
#
. /usr/share/libubox/jshn.sh

Width=0
StartRuler="1"
EndRuler="1"
LastErrors="1"
NormalColor=""
MachineColor=""
ValueColor=""
AddrColor=""
RXTXColor=""
ErrorColor=""
ExtraName=""
ExtraValue=""
HTML=""

initialize() { # <Script Parameters>
	local ColorMode="c"
	if [ ! -z "$REQUEST_METHOD" ]; then
		HTML="1"
		ColorMode="html"
		StartRuler=""
		EndRuler="1"
	fi
	[ -e /etc/banner ] && Width=$(awk 'BEGIN{max=0}{if(length($0)>max)max=length($0)}END{print max}' /etc/banner 2>/dev/null)
	while [ -n "$1" ]; do
		case "$1" in
		-h|--help)	echo -e	"Usage: $0 [-h|--help] [[-m|--mono]|[-bw|-black-white]|[-c2|--color-2]] [-sr|--no-start-ruler] [-er|--no-end-ruler]"\
							"[-w N|--width N] [-en Name|--extra-name Name] [-ev Value|--extra-value Value] [-le|--no-last-err]"\
							"\n\t-h\t\tThis help,"\
							"\n\t-m\t\tDisplay mono version,"\
							"\n\t-bw\t\tDisplay black-white version,"\
							"\n\t-c2\t\tDisplay alternative color version 2,"\
							"\n\t-sr\t\tWithout start horizontal ruler,"\
							"\n\t-er\t\tWithout end horizontal ruler,"\
							"\n\t-w N\t\tSet width of text area to N characters (minimum 60)"\
							"\n\t-en Name\tPrint extra name"\
							"\n\t-ev Value\tPrint extra value"\
							"\n\t-le\t\tDon't display last errors"
					exit 1;;
		-m|--mono) ColorMode="m";;
		-bw|--black-white) ColorMode="bw";;
		-c2|--color-2) ColorMode="c2";;
		-sr|--no-start-ruler) StartRuler="0";;
		-er|--no-end-ruler) EndRuler="0";;
		-w|--width) shift; Width=$1;;
		-en|--extra-name)	while [ -n "$2" ] && [ "${2:0:1}" != "-" ]; do
								shift
								[ "$ExtraName" != "" ] && ExtraName="$ExtraName "
								ExtraName="$ExtraName$1"
							done;;
		-ev|--extra-value)	while [ -n "$2" ] && [ "${2:0:1}" != "-" ]; do
								shift
								[ "$ExtraValue" != "" ] && ExtraValue="$ExtraValue "
								ExtraValue="$ExtraValue$1"
							done;;
		-le|--no-last-err)	LastErrors="0";;
		*) echo "Invalid option: $1. Use -h for help";;
		esac
		shift;
	done
	case "$ColorMode" in
		c)	NormalColor="\e[0m"
			MachineColor="\e[0;33m"
			ValueColor="\e[1;36m"
			AddrColor="\e[1;31m"
			RXTXColor="\e[2;32m"
			ErrorColor="\e[0;31m";;
		c2)	NormalColor="\e[0m"
			MachineColor="\e[0;31m"
			ValueColor="\e[0;33m"
			AddrColor="\e[0;35m"
			RXTXColor="\e[0;36m"
			ErrorColor="\e[0;31m";;
		m)	NormalColor="\e[0m"
			MachineColor="\e[7m"
			ValueColor="\e[1m"
			AddrColor="\e[4m"
			RXTXColor="\e[1m"
			ErrorColor="\e[4";;
		html)	NormalColor="</font><font class=\"Normal\">"
			MachineColor="</font><font class=\"Machine\">"
			ValueColor="</font><font class=\"Value\">"
			AddrColor="</font><font class=\"Addr\">"
			RXTXColor="</font><font class=\"RXTX\">"
			ErrorColor="</font><font class=\"Error\">";;
		*)	;;
	esac
	([ "$Width" == "" ] || [ "$Width" -lt 65 ]) && Width=65
	if [ "$HTML" == "1" ]; then
		echo "Content-type: text/html"
		echo ""
		cat << EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	</head>
	<style>
		body {font-family:Consolas,Terminal,"Lucida Console",Courier,Monaco,monospace;
			font-size:1em;white-space:pre-wrap;word-wrap:break-word;line-height:1.2em;
			color:#bbbbbb;background-color:#000000}
		.Normal {color:#bbbbbb}
		.Machine  {color:#bbbb00}
		.Value {color:#00ffff}
		.Addr {color:#ee5555}
		.RXTX {color:#00bb00}
	</style>
	<body>
EOF
		[ -e /etc/banner ] && cat /etc/banner
	fi
}

finalize() {
	if [ "$HTML" == "1" ]; then
		cat << EOF
	</body>
</html>
EOF
	fi
}

human_readable() { # <Number of bytes>
	if [ $1 -gt 0 ]; then
		printf "$(awk -v n=$1 'BEGIN{for(i=split("B KB MB GB TB PB",suffix);s<1;i--)s=n/(2**(10*i));printf (int(s)==s)?"%.0f%s":"%.1f%s",s,suffix[i+2]}' 2>/dev/null)"
	else
		printf "0B"
	fi
}

device_rx_tx() { # <Device>
	local RXTX=$(awk -v Device=$1 '$1==Device ":"{printf "%.0f\t%.0f",$2,$10}' /proc/net/dev 2>/dev/null)
	[ "$RXTX" != "" ] && printf ", rx/tx: $RXTXColor$(human_readable $(echo "$RXTX" | cut -f 1))$NormalColor/$RXTXColor$(human_readable $(echo "$RXTX" | cut -f 2))$NormalColor"
}

uptime_str() { # <Time in Seconds>
	local Uptime=$1
	if [ $Uptime -gt 0 ]; then
		local Days=$(expr $Uptime / 60 / 60 / 24)
		local Hours=$(expr $Uptime / 60 / 60 % 24)
		local Minutes=$(expr $Uptime / 60 % 60)
		local Seconds=$(expr $Uptime % 60)
		if [ $Days -gt 0 ]; then
			Days=$(printf "%dd " $Days)
		else
			Days=""
		fi 2>/dev/null
		printf "$Days%02d:%02d:%02d" $Hours $Minutes $Seconds
	fi
}

print_line() { # <String to Print>, [[<String to Print>] ...]
	local Line="$@"
	if [ "$HTML" == "1" ]; then
		printf "   $Line\n" 2>/dev/null
	else
		printf " | %-$(expr $Width - 5)s |\r | $Line\n" 2>/dev/null
	fi
}

print_line_error() { # <String to Print>, [[<String to Print>] ...]
	local Line="$@"
	if [ "$HTML" == "1" ]; then
		printf "   $Line\n" 2>/dev/null
	else
		printf "   %-$(expr $Width - 5)s  \r   $Line\n" 2>/dev/null
	fi
}

print_horizontal_ruler() {
	printf "/%$(expr $Width - 1)s\n" | tr ' /' '- ' 2>/dev/null
}

print_machine() {
	local Machine=""
	local HostName=$(uci -q get system.@system[0].hostname)
	if [ -e /tmp/sysinfo/model ]; then
		Machine=$(cat /tmp/sysinfo/model 2>/dev/null)
	elif [ -e /proc/cpuinfo ]; then
		Machine=$(awk 'BEGIN{FS="[ \t]+:[ \t]";OFS=""}/machine/{Machine=$2}/Hardware/{Hardware=$2}END{print Machine,(Machine!="" && Hardware!="")?" ":"",Hardware}' /proc/cpuinfo 2>/dev/null)
	fi
	print_line "${NormalColor}Machine: $MachineColor${Machine:-n/a}$NormalColor,"\
			"Name: $MachineColor${HostName:-n/a}$NormalColor"
}

print_times() {
	local SysUptime=$(cut -d. -f1 /proc/uptime)
	local Uptime=$(uptime_str $SysUptime)
	local Now=$(date +'%Y-%m-%d %H:%M:%S')
	print_line 	"System uptime: $ValueColor$Uptime$NormalColor,"\
				"Now: $ValueColor$Now$NormalColor"
}

print_loadavg() {
	print_line "System load:"\
				"$ValueColor"$(cat /proc/loadavg | cut -d " " -f 1 2>/dev/null)"$NormalColor,"\
				"$ValueColor"$(cat /proc/loadavg | cut -d " " -f 2 2>/dev/null)"$NormalColor,"\
				"$ValueColor"$(cat /proc/loadavg | cut -d " " -f 3 2>/dev/null)"$NormalColor"
}

print_fs_summary() { # <Mount point> <Label>
	local DeviceInfo=$(df -k $1 2>/dev/null| awk 'BEGIN{Total=0;Free=0} NR>1 && $6=="'$1'"{Total=$2;Free=$4}END{Used=Total-Free;printf"%.0f\t%.0f\t%.1f\t%.0f",Total*1024,Used*1024,(Total>0)?((Used/Total)*100):0,Free*1024}' 2>/dev/null)
	local Total=$(echo "$DeviceInfo" | cut -f 1)
	local Used=$(echo "$DeviceInfo" | cut -f 2)
	local UsedPercent=$(echo "$DeviceInfo" | cut -f 3)
	local Free=$(echo "$DeviceInfo" | cut -f 4)
	[ "$Total" -gt 0 ] && print_line "$2:"\
				"total: $ValueColor$(human_readable $Total)$NormalColor,"\
				"used: $ValueColor$(human_readable $Used)$NormalColor, $ValueColor$UsedPercent$NormalColor%%,"\
				"free: $ValueColor$(human_readable $Free)$NormalColor"
}

print_disk() {
	local Overlay=$(awk '$3=="overlayfs"{print $2}' /proc/mounts 2>/dev/null)
	if [ "$Overlay" != "" ]; then
		print_fs_summary /overlay "Flash"		
	fi
	if [ "$Overlay" == "" ] || [ "$Overlay" != "/" ]; then
		print_fs_summary / "RootFS"
	fi
}

print_memory() {
	local Memory=$(awk 'BEGIN{Total=0;Free=0}$1~/^MemTotal:/{Total=$2}$1~/^MemFree:|^Buffers:|^Cached:/{Free+=$2}END{Used=Total-Free;printf"%.0f\t%.0f\t%.1f\t%.0f",Total*1024,Used*1024,(Total>0)?((Used/Total)*100):0,Free*1024}' /proc/meminfo 2>/dev/null)
	local Total=$(echo "$Memory" | cut -f 1)
	local Used=$(echo "$Memory" | cut -f 2)
	local UsedPercent=$(echo "$Memory" | cut -f 3)
	local Free=$(echo "$Memory" | cut -f 4)
	print_line "Memory:"\
				"total: $ValueColor$(human_readable $Total)$NormalColor,"\
				"used: $ValueColor$(human_readable $Used)$NormalColor, $ValueColor$UsedPercent$NormalColor%%,"\
				"free: $ValueColor$(human_readable $Free)$NormalColor"
}

print_swap() {
	local Swap=$(awk 'BEGIN{Total=0;Free=0}$1~/^SwapTotal:/{Total=$2}$1~/^SwapFree:/{Free=$2}END{Used=Total-Free;printf"%.0f\t%.0f\t%.1f\t%.0f",Total*1024,Used*1024,(Total>0)?((Used/Total)*100):0,Free*1024}' /proc/meminfo 2>/dev/null)
	local Total=$(echo "$Swap" | cut -f 1)
	local Used=$(echo "$Swap" | cut -f 2)
	local UsedPercent=$(echo "$Swap" | cut -f 3)
	local Free=$(echo "$Swap" | cut -f 4)
	[ "$Total" -gt 0 ] && print_line "Swap:"\
				"total: $ValueColor$(human_readable $Total)$NormalColor,"\
				"used: $ValueColor$(human_readable $Used)$NormalColor, $ValueColor$UsedPercent$NormalColor%%,"\
				"free: $ValueColor$(human_readable $Free)$NormalColor"
}

print_wan() {
	local Zone
	local Device
	for Zone in $(uci -q show firewall | grep .masq= | cut -f2 -d.); do
		if [ "$(uci -q get firewall.$Zone.masq)" == "1" ]; then
			for Device in $(uci -q get firewall.$Zone.network); do
				local Status="$(ubus call network.interface.$Device status 2>/dev/null)"
				if [ "$Status" != "" ]; then
					local State=""
					local Iface=""
					local Uptime=""
					local IP4=""
					local IP6=""
					local Subnet4=""
					local Subnet6=""
					local Gateway4=""
					local Gateway6=""
					local DNS=""
					local Protocol=""
					json_load "${Status:-{}}"
					json_get_var State up
					json_get_var Uptime uptime
					json_get_var Iface l3_device
					json_get_var Protocol proto
					if json_get_type Status ipv4_address && [ "$Status" = array ]; then
						json_select ipv4_address
						json_get_type Status 1
						if [ "$Status" = object ]; then
							json_select 1
							json_get_var IP4 address
							json_get_var Subnet4 mask
							[ "$IP4" != "" ] && [ "$Subnet4" != "" ] && IP4="$IP4/$Subnet4"
						fi
					fi
					json_select
					if json_get_type Status ipv6_address && [ "$Status" = array ]; then
						json_select ipv6_address
						json_get_type Status 1
						if [ "$Status" = object ]; then
							json_select 1
							json_get_var IP6 address
							json_get_var Subnet6 mask
							[ "$IP6" != "" ] && [ "$Subnet6" != "" ] && IP6="$IP6/$Subnet6"
						fi
					fi
					json_select
					if json_get_type Status route && [ "$Status" = array ]; then
						json_select route
						local Index="1"
						while json_get_type Status $Index && [ "$Status" = object ]; do
							json_select "$((Index++))"
							json_get_var Status target
							case "$Status" in
								0.0.0.0)
									json_get_var Gateway4 nexthop;;
								::)
									json_get_var Gateway6 nexthop;;
							esac
							json_select ".."
						done	
					fi
					json_select
					if json_get_type Status dns_server && [ "$Status" = array ]; then
						json_select dns_server
						local Index="1"
						while json_get_type Status $Index && [ "$Status" = string ]; do
							json_get_var Status "$((Index++))"
							DNS="${DNS:+$DNS }$Status"
						done
					fi
					if [ "$State" == "1" ]; then
						[ "$IP4" != "" ] && print_line 	"WAN: $AddrColor$IP4$NormalColor($Iface),\n"\
														"gateway: $AddrColor${Gateway4:-n/a}$NormalColor"
						[ "$IP6" != "" ] && print_line	"WAN: $AddrColor$IP6$NormalColor($Iface),\n"\
														"gateway: $AddrColor${Gateway6:-n/a}$NormalColor"
						print_line	"proto: $ValueColor${Protocol:-n/a}$NormalColor,"\
									"uptime: $ValueColor$(uptime_str $Uptime)$NormalColor$(device_rx_tx $Iface)"
						[ "$DNS" != "" ] && print_line "dns: $AddrColor$DNS$NormalColor"
					fi
				fi
			done
		fi 
	done
}

print_lan() {
	local Zone
	local Device
	for Zone in $(uci -q show firewall | grep []]=zone | cut -f2 -d. | cut -f1 -d=); do
		if [ "$(uci -q get firewall.$Zone.masq)" != "1" ]; then
			for Device in $(uci -q get firewall.$Zone.network); do
				local Status="$(ubus call network.interface.$Device status 2>/dev/null)"
				if [ "$Status" != "" ]; then
					local State=""
					local Iface=""
					local IP4=""
					local IP6=""
					local Subnet4=""
					local Subnet6=""
					json_load "${Status:-{}}"
					json_get_var State up
					json_get_var Iface device
					if json_get_type Status ipv4_address && [ "$Status" = array ]; then
						json_select ipv4_address
						json_get_type Status 1
						if [ "$Status" = object ]; then
							json_select 1
							json_get_var IP4 address
							json_get_var Subnet4 mask
							[ "$IP4" != "" ] && [ "$Subnet4" != "" ] && IP4="$IP4/$Subnet4"
						fi
					fi
					json_select
					if json_get_type Status ipv6_address && [ "$Status" = array ]; then
						json_select ipv6_address
						json_get_type Status 1
						if [ "$Status" = object ]; then
							json_select 1
							json_get_var IP6 address
							json_get_var Subnet6 mask
							[ "$IP6" != "" ] && [ "$Subnet6" != "" ] && IP6="$IP6/$Subnet6"
						fi
					fi
					local DHCPConfig=$(uci -q show dhcp | grep .interface=$Device | cut -d. -f2)
					if [ "$DHCPConfig" != "" ] && [ "$(uci -q get dhcp.$DHCPConfig.ignore)" != "1" ]; then
						local DHCPStart=$(uci -q get dhcp.$DHCPConfig.start)
						local DHCPLimit=$(uci -q get dhcp.$DHCPConfig.limit)
						[ "$DHCPStart" != "" ] && [ "$DHCPLimit" != "" ] && DHCP="$(echo $IP4 | cut -d. -f1-3).$DHCPStart-$(expr $DHCPStart + $DHCPLimit - 1)"
					fi
					[ "$IP4" != "" ] && print_line "LAN: $AddrColor$IP4$NormalColor($Iface), dhcp: $AddrColor${DHCP:-n/a}$NormalColor"
					[ "$IP6" != "" ] && print_line "LAN: $AddrColor$IP6$NormalColor($Iface)"
				fi
			done
		fi 
	done
}

print_wlan() {
	local Iface
	for Iface in $(uci -q show wireless | grep device=radio | cut -f2 -d.); do
		local Device=$(uci -q get wireless.$Iface.device)
		local SSID=$(uci -q get wireless.$Iface.ssid)
		local IfaceDisabled=$(uci -q get wireless.$Iface.disabled)
		local DeviceDisabled=$(uci -q get wireless.$Device.disabled)
		if [ -n "$SSID" ] && [ "$IfaceDisabled" != "1" ] && [ "$DeviceDisabled" != "1" ]; then
			local Mode=$(uci -q -P /var/state get wireless.$Iface.mode)
			local Channel=$(uci -q get wireless.$Device.channel)
			local RadioIface=$(uci -q -P /var/state get wireless.$Iface.ifname)
			local Connection="Down"
			if [ -n "$RadioIface" ]; then
				if [ "$Mode" == "ap" ]; then
					Connection="$(iw dev $RadioIface station dump | grep Station | wc -l 2>/dev/null)"
				else
					Connection="$(iw dev $RadioIface link | awk 'BEGIN{FS=": ";Signal="";Bitrate=""} $1~/signal/ {Signal=$2} $1~/tx bitrate/ {Bitrate=$2}END{print Signal" "Bitrate}' 2>/dev/null)"
				fi
			fi
			if [ "$Mode" == "ap" ]; then
				print_line	"WLAN: $ValueColor$SSID$NormalColor($Mode),"\
							"ch: $ValueColor${Channel:-n/a}$NormalColor,"\
							"conn: $ValueColor$Connection$NormalColor$(device_rx_tx $RadioIface)"
			else
				print_line	"WLAN: $ValueColor$SSID$NormalColor($Mode),"\
							"ch: $ValueColor${Channel:-n/a}$NormalColor"
				print_line	"conn: $ValueColor$Connection$NormalColor$(device_rx_tx $RadioIface)"
			fi
		fi
	done
}

print_vpn() {
	local VPN
	for VPN in $(uci -q show openvpn | grep .ca= | cut -f2 -d.); do
		local Device=$(uci -q get openvpn.$VPN.dev)
		local Enabled=$(uci -q get openvpn.$VPN.enabled)
		if [ "$Enabled" == "1" ] || [ "$Enabled" == "" ]; then
			local Mode=$(uci -q get openvpn.$VPN.mode)
			local Connection="n/a"
			if [ "$Mode" == "server" ]; then
				Mode="$ValueColor$VPN$NormalColor(svr):$(uci -q get openvpn.$VPN.port)"
				Status=$(uci -q get openvpn.$VPN.status)
				Connection=$(awk 'BEGIN{FS=",";c=0;l=0}{if($1=="Common Name")l=1;else if($1=="ROUTING TABLE")exit;else if (l==1) c=c+1}END{print c}' $Status 2>/dev/null)
			else
				Mode="$ValueColor$VPN$NormalColor(cli)"
				Connection="Down"
				ifconfig $Device &>/dev/null && Connection="Up"
			fi
			print_line	"VPN: $Mode,"\
						"conn: $ValueColor$Connection$NormalColor$(device_rx_tx $Device)"
		fi
	done
}

print_extra() {
	([ "$ExtraName" != "" ] || [ "$ExtraValue" != "" ]) && print_line "$ExtraName $ValueColor$ExtraValue$NormalColor"
}

print_error() {
	print_line_error	"Last 'logread' errors:"
	logread | awk '/\w{3}+\.(err|warn|alert|emerg|crit)/{err[++i]=$0}END{j=i-4;j=j>=1?j:1;while(j<=i)print" '$ErrorColor'"err[j++]"'$NormalColor'"}' 2>/dev/null
}

initialize $@
[ "$StartRuler" == "1" ] && print_horizontal_ruler
print_machine
print_times
print_loadavg
print_disk
print_memory
print_swap
print_wan
print_lan
print_wlan
print_vpn
print_extra
[ "$EndRuler" == "1" ] && print_horizontal_ruler
[ "$LastErrors" == "1" ] && print_error
finalize
#exit 0
# Done.
