local code  = require "luci.pb.code"
local sauth = require "luci.controller.api.user"
local uci   = require("luci.model.uci").cursor()
local base      = require "luci.controller.api.index"
local PBUCI     = require "luci.pb.PBUCI"
local PBCommand = require "luci.pb.PBCommand"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()

module("luci.controller.api.hwacc", package.seeall)

function index ()
	entry({"api", "hwacc"}, call('action_hwnat'), nil, 93).index = true

	entry({'api', 'hwacc', 'status'}, call('getHwnat'), nil, 30)
	entry({'api', 'hwacc', 'setter'}, call('setHwnat'), nil, 40)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/hwacc") then
		return false
	end

	return true
end

function action_hwnat ()
	local V = PBUtil.getFormValue("_method")
	if not V['_method'] then
		return code.miss('Method+')
	elseif 'string' ~= type(V['_method']) then
		return code.error('Method+')
	else
		V['_method'] = V['_method']:upper()
	end

	if 'GET' == V['_method'] then
		return getHwnat()
	elseif 'PUT' == V['_method'] then
		return setHwnat()
	else
		return code.error('Method+')
	end
end

function _getHwnat ()
	local rv = {}

	if not moduleStatus() then
		return rv
	end

	uci:foreach('hwacc', 'hwnat',
		function (section)
			local obj        = {}
			obj.wname        = section[".name"]
			obj.enabled      = section.enabled or '0'
			obj.tcp_offload  = section.tcp_offload or nil
			obj.udp_offload  = section.udp_offload or nil
			obj.ipv6_offload = section.ipv6_offload or nil
			obj.wifi_offload = section.wifi_offload or nil

			rv[#rv+1] = obj
		end)

	return rv
end

function getHwnat ()
	local action = _getHwnat()
	if not action or #action == 0 then
		return code.code40011()
	end
	return code.ok(action)
end

function _setHwnat ()
	local wname        = luci.http.formvalue('wname') or nil
	local enabled      = luci.http.formvalue('enabled') or nil
	local udp_offload  = luci.http.formvalue('udp_offload') or nil
	local ipv6_offload = luci.http.formvalue('ipv6_offload') or nil
	local wifi_offload = luci.http.formvalue('wifi_offload') or nil

	if not wname then
		return code.miss('Wname+')
	end

	if not uci:get('hwacc', wname) then
		return code.code40004()
	elseif uci:get('hwacc', wname) ~= 'hwnat' then
		return code.error('Wname+')
	end

	if not enabled then
		return code.miss('Enabled+')
	end

	if enabled:match('%D') or (enabled ~= '0' and enabled ~= '1') then
		return code.error('Enabled+')
	end
	if enabled == '1' then
		if udp_offload then
			if udp_offload:match('%D') or (udp_offload ~= '0' and udp_offload ~= '1') then
				return code.error('UDP_offload+')
			end
		end
		if ipv6_offload then
			if ipv6_offload:match('%D') or (ipv6_offload ~= '0' and ipv6_offload ~= '1') then
				return code.error('IPv6_offload+')
			end
		end
		if wifi_offload then
			if wifi_offload:match('%D') or (wifi_offload ~= '0' and wifi_offload ~= '1') then
				return code.error('Wifi_offload+')
			end
		end
	end

	local hwnat = {}
	for _, value in ipairs(_getHwnat()) do
		if value.wname == wname then
			hwnat = value
		end
	end
	if hwnat.enabled == enabled and hwnat.udp_offload == udp_offload and
		hwnat.ipv6_offload == ipv6_offload and hwnat.wifi_offload == wifi_offload then
		return code.same()
	end

	if enabled then
		uci:set('hwacc', wname, 'enabled', enabled)
	end
	if enabled == '0' then
		uci:set('hwacc', wname, 'tcp_offload', '0')
	end
	if enabled == '1' then
		uci:set('hwacc', wname, 'tcp_offload', '1')
		if udp_offload then
			uci:set('hwacc', wname, 'udp_offload', udp_offload)
		end
		if ipv6_offload then
			uci:set('hwacc', wname, 'ipv6_offload', ipv6_offload)
		end
		if wifi_offload then
			uci:set('hwacc', wname, 'wifi_offload', wifi_offload)
		end
	end
end

function setHwnat ()
	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _setHwnat()
	if action then return end

	uci:commit('hwacc')

	getHwnat()

	luci.sys.exec("/etc/init.d/hwacc restart")
end
