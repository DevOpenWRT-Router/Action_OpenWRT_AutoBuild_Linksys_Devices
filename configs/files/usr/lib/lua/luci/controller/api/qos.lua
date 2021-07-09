local uci       = require("luci.model.uci").cursor()
local base      = require "luci.controller.api.index"
local PBCommand = require "luci.pb.PBCommand"
local PBUCI    = require "luci.pb.PBUCI"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()
local checker   = PBUtil.checker()

local version     = '0.1.1'
local version_num = 5

local qos_options = {version = version, version_num = version_num}

module("luci.controller.api.qos", package.seeall)

function index ()
	local page   = node("api", "qos")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 430
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "qos", "status"}, call("getQos"), nil, 0)
	entry({"api", "qos", "getter"}, alias("api", "qos", "status"), nil, 1)
	entry({"api", "qos", "getter", "global"}, call("getGlobalQos"), nil, 0)
	entry({"api", "qos", "getter", "client"}, call("getClientQos"), nil, 10)
	entry({"api", "qos", "getglobal"}, alias("api", "qos", "getter", "global"), nil, 2)
	entry({"api", "qos", "getclient"}, alias("api", "qos", "getter", "client"), nil, 3)

	entry({"api", "qos", "setter"}, call("setQos"), nil, 10)
	entry({"api", "qos", "setter", "power"}, call("setQosPower"), nil, 0)
	entry({"api", "qos", "setter", "global"}, call("setGlobalQos"), nil, 10)
	entry({"api", "qos", "setter", "client"}, call("setClientQos"), nil, 20)
	entry({"api", "qos", "setglobal"}, alias("api", "qos", "setter", "global"), nil, 11)
	entry({"api", "qos", "setclient"}, alias("api", "qos", "setter", "client"), nil, 12)

	entry({"api", "qos", "delete"}, call("deleteClientQos"), nil, 20)

	entry({"api", "qos", "blocklist"}, call("getBlockList"), nil, 80)
	entry({"api", "qos", "unblock"}, call("setUnblock"), nil, 82)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/bandwidth") then
		return false
	end
	if not nixio.fs.access("/etc/init.d/bandwidth") then
		return false
	end

	return true
end

function _getGlobalQos ()
	if uci:get("bandwidth", "main") ~= "bandwidth" then
		return nil
	end
	local qos = PBUtil.getUCISection('bandwidth', 'main')

	return qos
end

function getGlobalQos ()
	local action = _getGlobalQos()
	if not action then
		return code.empty("QoS Global+", qos_options)
	end

	return code.ok({ action }, qos_options)
end

function _getClientQos ()
	local qos = {}
	qos.ip    = {}
	qos.rang  = {}
	-- IP
	for _, item in ipairs(PBUtil.getUCIList('bandwidth', 'client_ip')) do
		if item.ipaddr:find('-') then
			item.start, item.limit = item.ipaddr:match('^(.*)-(.*)')
		end
		if item.start and item.limit then
			qos.rang[#qos.rang+1] = item
		else
			qos.ip[#qos.ip+1] = item
		end
	end

	-- MAC
	qos.mac = PBUtil.getUCIList('bandwidth', 'client_mac') or {}

	return qos
end

function getClientQos ()
	local action = _getClientQos()
	if not action then
		return code.empty("QoS Client+", qos_options)
	end

	return code.ok({ rv }, qos_options)
end

function _getQos ()
	local qos = {}
	-- Global
	qos.global = _getGlobalQos()
	if not qos.global then
		return code.empty("QoS Global+", qos_options)
	end
	-- clients
	qos.clients = _getClientQos()
	if not qos.clients then
		return code.empty("QoS Client+", qos_options)
	end

	return qos
end

function getQos ()
	local qos = _getQos()
	local rv = {}
	-- Import
	if qos and qos.global and qos.clients then
		rv[#rv+1] = qos
	end
	if #rv > 0 then
		return code.ok(rv, qos_options)
	else
		-- code.empty("QoS+", qos_options)
		return
	end
end

function setQosPower ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		'enabled'
	})

	if V.enabled and V.enabled:match('%D') then
		return code.error("Enabled+", qos_options)
	end

	V.enabled = tonumber(V.enabled)
	if V.enabled > 0 then
		V.enabled = 1
	else
		V.enabled = 0
	end

	if PBUCI.setUCISection('bandwidth', 'main', {
		enabled = V.enabled
	}) then
		getGlobalQos()
		PBCommand.run("/etc/init.d/bandwidth restart&")
	end

	-- getGlobalQos()

end

function _setGlobalQos ()
	if uci:get("bandwidth", "main") ~= "bandwidth" then
		return code.empty("Bandwidth Main+", qos_options)
	end
	local V = PBUtil.getFormValue({
		'enabled', 'upload', 'download',
		'reset_type', 'packets_threshold',
		'week', 'day', 'hour'
	})
	V.type = V.reset_type

	-- Checker
	if V.enabled and V.enabled:match('%D') then
		return code.error("Enabled+", qos_options)
	end
	if V.upload and V.upload:match('%D') then
		return code.error("Upload+", qos_options)
	end
	if V.download and V.download:match('%D') then
		return code.error("Download+", qos_options)
	end

	if V.type and not (
		V.type == "mouthly" or V.type == "weekly" or
		V.type == "daily" or V.type == "hourly") then
		return code.error("Reset Type+", qos_options)
	end
	if V.type then
		if V.type == "mouthly" then
			if not V.day then
				return code.miss("Day+", qos_options)
			end
			if not V.hour then
				return code.miss("Hour+", qos_options)
			end
			if V.day:match("%D") then
				return code.error("Day+", qos_options)
			end
			if V.hour:match("%D") then
				return code.error("Hour+", qos_options)
			end
		elseif V.type == "weekly" then
			if not V.week then
				return code.miss("Week+", qos_options)
			end
			if not V.hour then
				return code.miss("Hour+", qos_options)
			end
			if V.week:match("%D") then
				return code.error("Week+", qos_options)
			end
			if V.hour:match("%D") then
				return code.error("Hour+", qos_options)
			end
		elseif V.type == "daily" then
			if not V.hour then
				return code.miss("Hour+", qos_options)
			end
			if V.hour:match("%D") then
				return code.error("Hour+", qos_options)
			end
		elseif V.type == "hourly" then
			-- No hourly
		end
	end

	if not V.packets_threshold then
		return code.miss("Small-Packet+", qos_options)
	end
	if V.packets_threshold:match("%D") then
		return code.error("Small-Packet+", qos_options)
	end

	-- Setter
	if V.enabled then
		V.enabled = tonumber(V.enabled)
		if V.enabled > 0 then
			V.enabled = 1
		else
			V.enabled = 0
		end
	end
	if V.upload then
		V.upload = tonumber(V.upload)
		if V.upload < 0 then
			V.upload = 0
		end
	end
	if V.download then
		V.download = tonumber(V.download)
		if V.download < 0 then
			V.download = 0
		end
	end

	if V.week then
		V.week = tonumber(V.week)
		if V.week < 0 then
			V.week = 0
		elseif V.week > 6 then
			V.week = 6
		end
	end
	if V.day then
		V.day = tonumber(V.day)
		if V.day < 0 then
			V.day = 1
		elseif V.day > 31 then
			V.day = 31
		end
	end
	if V.hour then
		V.hour = tonumber(V.hour)
		if V.hour < 0 or V.hour > 23 then
			V.hour = 0
		end
	end

	if V.packets_threshold then
		V.packets_threshold = tonumber(V.packets_threshold)
		if V.packets_threshold < 0 then
			V.packets_threshold = 0
		end
	end

	if PBUCI.setUCISection('bandwidth', 'main', {
		enabled           = V.enabled,
		upload            = V.upload,
		download          = V.download,
		type              = V.type,
		week              = V.week,
		day               = V.day,
		hour              = V.hour,
		packets_threshold = V.packets_threshold
	}) then	PBCommand.run("/etc/init.d/bandwidth restart&") end

	return
end

function setGlobalQos ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local type   = luci.http.formvalue("type") or ""
	local action = nil
	if type == "global" then
		action = _setGlobalQos()
		if action then return action end
	end

	getQos()
end

function _setClientQos ()
	local V = PBUtil.getFormValue({
		"wname", "ipaddr", "start", "limit",
		"macaddr", "download", "upload",
		"download_threshold", "upload_threshold",
		"ports", "comment", "priority"
	})

	-- Checker
	-- IP Rang Checker
	if V.start and V.limit then
		if not checker.ipv4(V.start) then
			return code.error('start+', qos_options)
		end
		if not checker.ipv4(V.limit) then
			return code.error('limit+', qos_options)
		end
		V.ipaddr = V.start .. "-" .. V.limit
	end

	if not V.ipaddr and not V.macaddr then
		return code.miss("Target+", qos_options)
	end
	-- Simple IP Checker
	if V.ipaddr and not V.start and not V.limit and
		not checker.ipv4(V.ipaddr) then
		return code.error('IP Address+', qos_options)
	end
	-- Mac Checker
	if V.macaddr and not checker.mac(V.macaddr) then
		return code.error('MAC Address+', qos_options)
	end

	if not V.priority then
		return code.miss("Priority+", qos_options)
	end
	if V.priority:match("%D") then
		return code.error("Priority+", qos_options)
	end
	if not V.download then
		return code.miss("Download+", qos_options)
	end
	if V.download:match("%D") then
		return code.error("Download+", qos_options)
	end
	if not V.upload then
		return code.miss("Upload+", qos_options)
	end
	if V.upload:match("%D") then
		return code.error("Upload+", qos_options)
	end
	if not V.download_threshold then
		return code.miss("Download_threshold+", qos_options)
	end
	if V.download_threshold:match("%D") then
		return code.error("Download_threshold+", qos_options)
	end
	if not V.upload_threshold then
		return code.miss("Upload_threshold+", qos_options)
	end
	if V.upload_threshold:match("%D") then
		return code.error("Upload_threshold+", qos_options)
	end
	if not V.ports then
		return code.miss("Ports+", qos_options)
	end

	for _, item in ipairs({
		'download', 'upload', 'download_threshold', 'upload_threshold', 'priority'
	}) do
		if V[item] then
			if tonumber(V[item]) < 0 then
				V[item] = '0'
			end
		end
	end

	-- Setter
	V.wname = PBUCI.checkWname(V.wname, 'bandwidth', 'client_ip') or
		PBUCI.checkWname(V.wname, 'bandwidth', 'client_mac') or nil
	if V.ipaddr then
		PBUCI.getList('bandwidth', 'client_ip'):is({
			ipaddr  = V.ipaddr
		}, function (_, item)
			V.wname = item.wname
		end)
	elseif V.macaddr then
		PBUCI.getList('bandwidth', 'client_mac'):is({
			macaddr = V.macaddr
		}, function (_, item)
			V.wname = item.wname
		end)
	end

	if not V.wname then
		if V.ipaddr then
			V.wname = PBUCI.addUCISection("bandwidth", "client_ip")
		elseif V.macaddr then
			V.wname = PBUCI.addUCISection("bandwidth", "client_mac")
		end
	end

	if PBUCI.setUCISection('bandwidth', V.wname, {
		ipaddr             = V.ipaddr,
		macaddr            = V.macaddr,
		download           = V.download,
		upload             = V.upload,
		download_threshold = V.download_threshold,
		upload_threshold   = V.upload_threshold,
		ports              = V.ports,
		comment            = V.comment,
		priority           = V.priority
	}) then PBCommand.run("/etc/init.d/bandwidth restart&") end

	return
end

function setClientQos ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local type = luci.http.formvalue("type") or ""
	local action = nil
	if type == "client" then
		action = _setClientQos()
		if action then return action end
	end

	getQos()
end


function setQos ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local type = luci.http.formvalue("type") or ""
	local action = nil

	if not type then
		return code.miss("Type+", qos_options)
	elseif type == "global" then
		action = _setGlobalQos()
		if action then return action end
	elseif type == "client" then
		action = _setClientQos()
		if action then return action end
	else
		return code.error("Type+", qos_options)
	end

	getQos()
end

function _deleteClientQos ()
	local V = PBUtil.getFormValue({
		'wname'
	})
	if not V.wname then
		return code.miss("Wname+", qos_options)
	end
	V.wname = PBUCI.checkWname(V.wname, 'bandwidth', 'client_ip') or
		PBUCI.checkWname(V.wname, 'bandwidth', 'client_mac')

	if not V.wname then
		return code.nowname(nil, qos_options)
	end

	uci:delete('bandwidth', V.wname)
	uci:commit('bandwidth')

	PBCommand.run("/etc/init.d/bandwidth restart&")

	return
end

function deleteClientQos ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _deleteClientQos()
	if action then return action end

	getQos()
end

--[[
	获取小黑屋列表

	@since 0.2.0

	@return {Array}
--]]
function _getBlockList ()
	local bwc = io.popen("cat /proc/bandwidth 2>/dev/null")
	local rv  = {}

	if bwc then
		local ln
		repeat
			ln = bwc:read("*l")
			if not ln then break end
			local obj = {}
			obj.ip, obj.mac, obj.disabled =
				ln:match("(%d*\.%d*\.%d*\.%d*) (%w+:%w+:%w+:%w+:%w+:%w+) .+,(%d+)$")
			if obj.disabled then
				rv[#rv+1] = obj
			end
		until not ln
	end

	return rv
end

--[[
	获取小黑屋列表的接口

	@see _getBlockList()
	@since 0.2.0

--]]
function getBlockList ()
	local rv = _getBlockList()

	if #rv > 0 then
		return code.ok(rv, qos_options)
	else
		return code.empty('Block List+', qos_options)
	end
end

--[[
	指定IP/MAC离开小黑屋信息

	@since 0.2.0
	@param {String} ipaddr
	@param {String} macaddr

	@return @see getBlockList()
--]]
function setUnblock ()
	local V = PBUtil.getFormValue({
		'ipaddr', 'macaddr'
	})

	if not V.ipaddr then
		return code.miss('IP Address+', qos_options)
	end
	if not V.macaddr then
		return code.miss('MAC Address+', qos_options)
	end
	if not checker.ipv4(V.ipaddr) then
		return code.error('IP Address+', qos_options)
	end
	if not checker.mac(V.macaddr) then
		return code.error('MAC Address+', qos_options)
	end

	PBCommand.run('echo "' .. V.macaddr .. '=' .. V.ipaddr ..'" > /proc/bandwidth')

	return getBlockList()
end
