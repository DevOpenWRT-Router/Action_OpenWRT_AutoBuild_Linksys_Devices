local uci       = require('luci.model.uci').cursor()
local base      = require 'luci.controller.api.index'
local PBCommand = require "luci.pb.PBCommand"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()

local version     = '0.1.1'
local version_num = 3

local upnp_options = {version = version, version_num = version_num}

module('luci.controller.api.upnp', package.seeall)

function index ()
	if not nixio.fs.access('/etc/config/upnpd') then
		return
	end

	local page   = node('api', 'upnp')
	page.target  = firstchild()
	page.title   = nil
	page.order   = 430
	page.sysauth = false
	page.ucidata = true
	page.index   = true


	entry({'api', 'upnp', 'list'}, call('getUpnpList'), nil, 0)
	entry({'api', 'upnp', 'power'}, call('action_power'), nil, 5)
	entry({'api', 'upnp', 'status'}, call('action_status'), nil, 10)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/upnpd") then
		return false
	end

	return true
end

function _getUpnpList ()
	local ipt = io.popen('iptables --line-numbers -t nat -xnvL MINIUPNPD')
	local rv = { }
	if ipt then
		while true do
			local ln = ipt:read('*l')
			if not ln then
				break
			elseif ln:match('^%d+') then
				local num, proto, extport, intaddr, intport =
					ln:match('^(%d+).-([a-z]+).-dpt:(%d+) to:(%S-):(%d+)')

				if num and proto and extport and intaddr and intport then
					num     = tonumber(num)
					extport = tonumber(extport)
					intport = tonumber(intport)

					rv[#rv+1] = {
						num     = num,
						proto   = proto:upper(),
						extport = extport,
						intaddr = intaddr,
						intport = intport
					}
				end
			end
		end

		ipt:close()
	end

	return rv
end

function getUpnpList ()
	local action = _getUpnpList() or {}

	if #action ~= 0 then
		return code.ok(action, upnp_options)
	else
		return code.empty('UPnP+', upnp_options)
	end
	return code.code40010('upnp.lua->getUpnpList+', upnp_options)
end

function _getUpnpPower ()
	return PBUtil.getUCISection('upnpd', 'config') or {}
end

function _setUpnpPower ()
	local V = PBUtil.getFormValue({
		'enable_upnp', 'enable_natpmp', 'secure_mode', 'log_output'
	})
	V.enable_natpmp = V.enable_natpmp or V.enable_upnp

	if V.enable_natpmp and V.enable_natpmp:match('^[2-9\D]$') then
		return code.error('enable_natpmp+', upnp_options)
	end
	if V.enable_upnp and V.enable_upnp:match('^[2-9\D]$') then
		return code.error('enable_upnp+', upnp_options)
	end
	if V.secure_mode and V.secure_mode:match('^[2-9\D]$') then
		return code.error('secure_mode+', upnp_options)
	end
	if V.log_output and V.log_output:match('^[2-9\D]$') then
		return code.error('log_output+', upnp_options)
	end

	local isSuc = PBUtil.setUCISection('upnpd', 'config', {
		enable_natpmp = V.enable_natpmp,
		enable_upnp   = V.enable_upnp,
		secure_mode   = V.secure_mode,
		log_output    = V.log_output
	})

	uci:commit('upnpd')

	if isSuc then PBCommand.run("/etc/init.d/miniupnpd restart") end
end

function action_power ()
	local V = PBUtil.getFormValue({
		'enable_upnp', 'enable_natpmp', 'secure_mode', 'log_output'
	})
	if (V.enable_natpmp and V.enable_natpmp:match('^[01]$')) or
		(V.enable_upnp and V.enable_upnp:match('^[01]$')) or
		(V.secure_mode and V.secure_mode:match('^[01]$')) or
		(V.log_output and V.log_output:match('^[01]$')) then
		local _apiAuth = base.checkApiAuth()
		if _apiAuth then return _apiAuth end

		if _setUpnpPower() then return end

	end

	return code.ok(_getUpnpPower(), upnp_options)
end

function action_status ()
	local rv = _getUpnpPower()

	local action = _getUpnpList() or {}
	rv.list = action

	return code.ok({rv}, upnp_options)
end
