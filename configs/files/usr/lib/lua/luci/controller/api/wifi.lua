local uci       = require("luci.model.uci").cursor()
local base      = require "luci.controller.api.index"
local PBUCI     = require "luci.pb.PBUCI"
local PBCommand = require "luci.pb.PBCommand"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()

module("luci.controller.api.wifi", package.seeall)

function index ()
	local page   = node("api", "wifi")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 300
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "wifi", "status"}, call("getWifi"), nil, 10)
	entry({"api", "wifi", "setter"}, call("setWifi"), nil, 20)
	entry({"api", "wifi", "power"}, call("action_power"), nil, 25)
	entry({"api", "wifi", "channel"}, call("getFreqlist"), nil, 30)
	entry({"api", "wifi", "scan"}, call("action_scan"), nil, 30)
	entry({"api", "wifi", "join"}, firstchild(), nil, 35)
	entry({"api", "wifi", "join", "setter"}, call("action_join"), nil, 10)
	entry({"api", "wifi", "join", "power"}, call("action_join_power"), nil, 15)
	entry({"api", "wifi", "join", "status"}, call("action_join_status"), nil, 20)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/wireless") then
		return false
	end

	if #PBUCI.getUCIList('wireless', 'wifi-iface') == 0 then
		return false
	end

	return true
end

local wifi_networks = nil

--[[
	获取Wifi 信息的Factory

	@since 0.3.0
	@param {Array}  devices
	@param {String} _type

	@return {Array}
--]]
function _getWifiBuild (devices, _type)
	local function isCurrentType (device)
		local device = PBUCI.getUCISection('wireless', device)
		if _type == '2.4' then
			if device.htmode:match('^HT') or (device.htmode == 'auto' and not device.hwmode:match('a$')) then
				return true
			end
		end
		if _type == '5.8' then
			if device.htmode:match('^VHT') or (device.htmode == 'auto' and device.hwmode:match('a$')) then
				return true
			end
		end
		return false
	end

	local rv = {}
	wifi_networks = wifi_networks or require('luci.tools.status').wifi_networks()
	PBUCI.getList('wireless', 'wifi-iface'):each(function (_, v)
		if v.mode == 'ap' and isCurrentType(v.device) then
			rv[#rv+1] = v
			if base.checkAuth() then
				for _, wifi in ipairs(wifi_networks) do
					if v.device == wifi.device then
						for _, network in ipairs(wifi.networks) do
							if network.link and network.link:match(v.device .. '%.network' .. #rv) then
								network.ifname     = nil
								network.link       = nil
								network.encryption = nil
								network.up         = nil
								network.name       = nil
								network.ssid       = nil
								v.status           = network
							end
						end
					end
				end
			end
		end
	end)

	for _, v in ipairs(rv) do
		local _tmp    = PBUCI.getUCISection('wireless', v.device)
		_tmp.disabled = nil

		v             = PBUtil.mergeTable(v, _tmp)
		v.freqlist    = _getFreqlist(v.device)
		v.type        = _type
		if not base.checkAuth() then
			v.encryption = nil
			v.key        = nil
		end
		if uci:get("user", "sys", "expert") ~= "1" then
			v.txpower = nil
			v.htmode  = nil
			v.noscan  = nil
		end
	end

	if #rv == 0 then return nil end

	return rv
end

--[[
	获取2.4G Wifi 信息

	@since 0.3.0
	@param {String} stok     [可选]
	@param {String} sysauth  [可选]

	@return {Array}
--]]
function _getWifi24 ()
	local devices = {
		'ra0', 'ra1', 'ra2', 'ra3',
		'ra4', 'ra5', 'ra6', 'ra7',
		'wds0', 'wds1', 'wds2', 'wds3',
		'acili0'
	}
	return _getWifiBuild(devices, '2.4')
end

--[[
	获取5.8G Wifi 信息

	@since 0.3.0
	@param {String} stok     [可选]
	@param {String} sysauth  [可选]

	@return {Array}
--]]
function _getWifi58 ()
	local devices = {
		'rai0', 'rai1', 'rai2', 'rai3',
		'rai4', 'rai5', 'rai6', 'rai7',
		'wdsi0', 'wdsi1', 'wdsi2', 'wdsi3',
		'acilii0'
	}
	return _getWifiBuild(devices, '5.8')
end

--[[
	获取Wifi 信息

	@see _getWifi24()
	@see _getWifi58()
	@since 0.1.0
--]]
function getWifi ()
	local wifi24 = _getWifi24()
	local wifi58 = _getWifi58()
	local rv     = {}
	-- Import
	if wifi24 then
		for _, item in ipairs(wifi24) do
			rv[#rv+1] = item
		end
	end
	if wifi58 then
		for _, item in ipairs(wifi58) do
			rv[#rv+1] = item
		end
	end
	if #rv > 0 then
		return code.code0(rv)
	else
		return code.code40003("Wireless+")
	end
end

--[[
	获取Wifi 开关信息

	@since 0.3.0
	@return {Array}
--]]
function _getWifiPower()
	local wifi24 = _getWifi24()
	local wifi58 = _getWifi58()
	local wifi   = {}
	local rv     = {}
	-- Import
	if wifi24 then
		for _, item in ipairs(wifi24) do
			wifi[#wifi+1] = item
		end
	end
	if wifi58 then
		for _, item in ipairs(wifi58) do
			wifi[#wifi+1] = item
		end
	end

	for _, v in ipairs(wifi) do
		local obj = {
			wname    = v.wname,
			type     = v.type,
			device   = v.device,
			disabled = v.disabled,
			ssid     = v.ssid
		}
		rv[#rv+1] = obj
	end

	return rv
end

--[[
	获取/设置Wifi 开关信息

	@see _getWifiPower()
	@see _setWifiPower()
	@since 0.3.0
--]]
function action_power ()
	local V = PBUtil.getFormValue({ 'wname', 'disabled' })

	if V.wname and V.disabled then
		local action = _setWifi()
		if action then return end
		PBCommand.run('ubus call network reload')
	end

	local rv = _getWifiPower()
	if #rv > 0 then
		return code.code0(rv)
	else
		return code.code40003("Wireless Power+")
	end
end

function _getFreqlist (device)
	local freq = nil
	local ipt  = io.popen("iwinfo " .. device .. " freqlist")
	if ipt then
		freq = {}
		while true do
			local ln = ipt:read()
			if not ln then
				break
			else
				local ac, hz, ch = ln:match("^(\*?).-(%d.*GHz).*(Channel %d+)")
				ac = (ac~="" and "true") or nil
				freq[#freq+1] = {
					active  = ac,
					freq    = hz,
					channel = ch
				}
			end
		end

		ipt:close()
	end

	return freq
end

function getFreqlist ()
	local device = luci.http.formvalue("device") or nil
	if not device then
		return code.code40001("Device+")
	end
	if "wifi-device" ~= uci:get("wireless", device) then
		return code.code40005()
	end

	local rv = {}
	local freqlist = _getFreqlist(device)

	if #freqlist > 0 then
		rv = freqlist
	else
		return code.code40003("Device " .. device .. " freq+")
	end

	code.code0(rv)
	return
end

function _setWifi ()
	local V = PBUtil.getFormValue({
		'channel', 'disabled', 'device',
		'encryption', 'ssid', 'key',
		'txpower', 'htmode', 'noscan',
		'wname'
	})

	if not PBUCI.checkWname(V.wname, 'wireless', 'wifi-iface') then
		return code.code40005()
	end

	-- Checker Start
	if V.ssid then
		if string.len(V.ssid) < 1 or string.len(V.ssid) > 256 then
			return code.code40002("+SSID Must Be At Least 1 Character And Not To Exceed 256 Character")
		end
	end
	if V.disabled then
		if (V.disabled:match('%D') or (V.disabled ~= "0" and V.disabled ~= "1")) then
			return code.code40002("Disabled+");
		end
	end
	if V.encryption and V.encryption ~= "none" then
		if not V.key then
			return code.code40001("Key+")
		elseif V.key and string.len(V.key) < 8 then
			return code.code40002("+Key Must Be At Least 8 Character.")
		end
	end
	if V.channel then
		-- @TODO 信道判断
		if V.channel ~= 'auto' and
			(string.len(V.channel) == 0 or V.channel:match('%D')) then
			return code.code40002("Channel")
		end
	end
	if V.txpower then
		if type(V.txpower) ~= 'string' then
			return code.code40002("Txpower+")
		end
		if string.len(V.txpower) == 0 or V.txpower:match('%D') or
			not (tonumber(V.txpower) > 0 and tonumber(V.txpower) <= 100) then
			return code.code40002("Txpower+")
		end
	end
	if V.htmode then
		-- @TODO 判断模式
	end
	if V.noscan then
		if (V.noscan:match('%D') or (V.noscan ~= "0" and V.noscan ~= "1")) then
			return code.code40002("Scan+");
		end
	end
	-- Checker End

	-- Setter Start
	PBUCI.setUCISection('wireless', V.wname, {
		disabled = V.disabled,
		ssid = V.ssid,
		encryption = V.encryption
	})
	if encryption ~= 'none' then
		PBUCI.setUCISection('wireless', V.wname, {
			key = V.key
		})
	end
	if not V.device then
		V.device = PBUCI.getUCISection('wireless', V.wname, 'device')
	end
	PBUCI.setUCISection('wireless', V.device, {
		channel  = V.channel,
		txpower  = V.txpower,
		noscan   = V.noscan
	})

	return nil
end

function setWifi ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _setWifi()
	if action then return action end

	uci:commit("wireless")
	uci:commit("network")

	getWifi()

	-- os.execute("sleep 1")
	-- luci.sys.exec("wifi")
	-- `ubus reload`会掉WIFI
	-- luci.sys.exec("ubus call network reload")
	-- network restart 涉及有线
	-- luci.sys.exec("/etc/init.d/network restart")
	local V = PBUtil.getFormValue('finish')
	if V.finish and V.finish == '1' then
		luci.sys.exec("wifi down;wifi up")
	end
end

function _scanWifi (device)
	local iw = luci.sys.wifi.getiwinfo(device)

	local times = 3
	local tmp = {}
	local rv = {}
	for i = 1, times do
		for k, v in ipairs(iw.scanlist or {}) do
			if not tmp[v.bssid] then
				rv[#rv+1] = v
				v.encryption.wep = v.encryption.wep and 1 or 0
				tmp[v.bssid] = true
			end
		end
	end

	return rv
end

--[[
	获取周边的Wifi 信息

	@since 0.3.0
	@param {String}  devices

	@return {Array}
--]]
function action_scan ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		'device'
	})

	if not V.device then
		return code.miss('Device+')
	end

	local action = _scanWifi(V.device)
	if not action then
		return code.error()
	end

	if #action > 0 then
		return code.ok(action)
	else
		return code.empty()
	end
	return
end

--[[
	中继Wifi

	@since 0.3.0
	@param {Array}  devices

	@return {Array}
--]]
function action_join ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local KEYS = { 'bssid', 'device', 'encryption', 'key', 'mode', 'network',
		'ssid', 'channel', 'disabled' }

	local V    = PBUtil.getFormValue(KEYS)
	V.mode     = V.mode or 'sta'
	V.network  = V.network or 'wwan'
	V.disabled = V.disabled or '0'

	for _, item in ipairs(KEYS) do
		if not V[item] and (item ~= 'key' and item ~= 'ssid') then
			return code.miss(item .. '+')
		end
	end

	-- Network
	if not PBUCI.exists('network', V.network) then
		PBUCI.setUCISection('network', V.network, 'interface')
	end
	PBUCI.setUCISection('network', V.network, {
		proto = 'dhcp'
	})
	-- Firewall
	local function getZone ()
		local wname = nil
		uci:foreach('firewall', 'zone', function (section)
			if section.input == 'REJECT' and
				section.output == 'ACCEPT' and
				section.forward == 'REJECT' then
				wname = section['.name']
			end
		end)
		return wname
	end
	local zone_wname = getZone() or nil
	if not zone_wname then
		zone_wname = PBUCI.addUCISection('firewall', 'zone', {
			name    = 'wan',
			input   = 'REJECT',
			output  = 'ACCEPT',
			forward = 'REJECT',
			masq    = '1',
			mtu_fix = '1'
		})
	end
	PBUCI.setUCISection('firewall', zone_wname, {
		network = 'wan wan6 ' .. V.network
	})
	-- Wireless
	local function getWireless ()
		local wname = nil

		uci:foreach('wireless', 'wifi-iface', function (section)
			if section.mode == V.mode then
				wname = section['.name']
			end
		end)

		return wname
	end
	local wireless_wname = getWireless() or nil
	if not wireless_wname then
		wireless_wname = PBUCI.addUCISection('wireless', 'wifi-iface', {
			mode   = V.mode
		})
		uci:commit('wireless')
	end
	PBUCI.setUCISection('wireless', wireless_wname, {
		disabled   = '0',
		bssid      = V.bssid,
		encryption = V.encryption,
		device     = V.device,
		key        = V.key,
		network    = V.network,
		ssid       = V.ssid
	})
	PBUCI.setUCISection('wireless', V.device, {
		channel  = V.channel,
		disabled = V.disabled
	})

	PBCommand.run("ubus call network reload")

	return code.ok()
end

function _action_join_status ()
	local rv = {}
	PBUCI.getList('wireless', 'wifi-iface'):is({
		mode = 'sta'
	}, function (_, wireless)
		rv = wireless
	end)
	if not rv.device then return false end

	local _deviceInfo = PBUCI.getUCISection('wireless', rv.device)
	_deviceInfo.disabled = nil

	rv = PBUtil.mergeTable(rv, _deviceInfo)

	if not rv.network then return false end

	local function findFirewallZone ()
		for _, zone in ipairs(PBUCI.getUCIList('firewall', 'zone') or {}) do
			if zone.input == 'REJECT' and
				zone.output  == 'ACCEPT' and
				zone.forward == 'REJECT' and
				zone.network:match(rv.network) then
				return true
			end
		end

		return false
	end

	if not findFirewallZone() then return false end

	rv = PBUtil.mergeTable(rv, PBUCI.getUCISection('network', rv.network))

	return rv
end

function action_join_status ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _action_join_status()
	if not action then return code.empty() end

	return code.ok({ action })
end

function action_join_power ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _action_join_status()
	if not action then return code.empty() end

	PBUCI.getList('firewall', 'zone'):is({
		input   == 'REJECT',
		output  == 'ACCEPT',
		forward == 'REJECT'
	}, function (_, zone)
		if zone.network and zone.network:match(action.network) then
			PBUCI.setSection('firewall', zone.wname, {
				network = zone.network:gsub(' ?' .. action.network, '')
			})
		end
	end)

	PBUCI.getList('wireless', 'wifi-iface'):is({
		mode = 'sta'
	}, function (_, wifi)
		PBUCI.setUCISection('wireless', wifi.wname, {
			disabled = '1'
		})
	end)

	if PBCommand.run("ubus call network reload") then
		return code.ok()
	end

	return code.empty()
end
