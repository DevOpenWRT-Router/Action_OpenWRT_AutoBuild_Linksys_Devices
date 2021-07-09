local uci = require("luci.model.uci").cursor()
local base = require "luci.controller.api.index"
local PBUtil = require 'luci.pb.PBUtil'
local code = PBUtil.message()

local version = '0.1.1'
local version_num = 4

local ddns_options = {version = version, version_num = version_num}

module("luci.controller.api.ddns", package.seeall)

function index ()
	if not nixio.fs.access("/etc/config/ddns") then
		return
	end

	local page   = node("api", "ddns")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 430
	page.sysauth = false
	page.ucidata = true
	page.index = true

	entry({"api", "ddns", "status"}, call("getDdns"), nil, 0)
	entry({"api", "ddns", "getter"}, call("getDdns"), nil, 10)
	entry({"api", "ddns", "list"}, call("getDdnsList"), nil, 15)
	entry({"api", "ddns", "setter"}, call("setDdns"), nil, 20)
	entry({"api", "ddns", "power"}, call("setDdnsPower"), nil, 22)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/ddns") then
		return false
	end

	return true
end

function _getDdns()
	local rv = {}

	local service_list = _getDdnsList()
	rv = PBUtil.getUCIList('ddns', 'service')
	for _, v in pairs(rv) do
		v.service_list = service_list

		v.enabled = v.enabled or '0'

		if not require('luci.controller.api.index').checkAuth() then
			v.username = nil
			v.password = nil
		end
	end

	if #rv == 0 then return nil end
	return rv
end

function getDdns ()
	local rv = {}
	local ddns = _getDdns()
	if ddns then
		rv = ddns
	else
		return code.empty("DDNS+", ddns_options)
	end

	return code.ok(rv, ddns_options)
end

function _setDdnsPower ()
	local V = PBUtil.getFormValue({
		'enabled', 'wname'
	})

	if not V.enabled then
		return code.miss("Enabled+", ddns_options)
	end
	if not V.wname then
		return code.miss("Wname+", ddns_options)
	end

	if V.enabled:match("%D") then
		return code.error("Enabled+", ddns_options)
	end
	if not PBUtil.checkWname(V.wname, 'ddns', 'service')then
		return code.error("Wname+", ddns_options)
	end

	if V.enabled == PBUtil.getUCISection('ddns', V.wname, 'enabled') then
		return code.code60001(nil, ddns_options)
	end

	PBUtil.setUCISection('ddns', V.wname, {
		enabled = V.enabled
	})

	uci:commit('ddns')

	return
end

function _setDdns ()
	local V = PBUtil.getFormValue({
		'interface',
		'update_url',
		'use_ipv6',
		'use_syslog',
		'use_https',
		'force_interval',
		'force_unit',
		'ip_source',
		'ip_interface',
		'check_interval',
		'check_unit',
		'retry_interval',
		'retry_unit',

		'enabled',
		'wname',
		'service_name',
		'domain',
		'service_username',
		'service_password'
	})

	if not V.wname then
		return code.miss("Wname+", ddns_options)
	end
	if not PBUtil.checkWname(V.wname, 'ddns', 'service') then
		return code.error("Wname+", ddns_options)
	end

	if not V.service_name then
		return code.miss("Service_name+", ddns_options)
	end
	if not V.domain then
		return code.miss("Domain+", ddns_options)
	end
	if not V.service_username then
		return code.miss("Username+", ddns_options)
	else
		V.username = V.service_username
	end
	if not V.service_password then
		return code.miss("Password+", ddns_options)
	else
		V.password = V.service_password
	end

	local ddns = nil
	for _, v in ipairs(_getDdns()) do
		if v.wname == V.wname then
			ddns = v
		end
	end
	if not ddns then
		return code.error("Section+", ddns_options)
	end

	if V.service_name == ddns.service_name and
		V.domain == ddns.domain and
		V.username == ddns.username and
		V.password == ddns.password then
		if V.enabled then
			if V.enabled == ddns.enabled then
				return code.code60001(nil, ddns_options)
			end
		else
			return code.code60001(nil, ddns_options)
		end
	end

	PBUtil.setUCISection("ddns", V.wname, {
		interface = V.interface,
		update_url = V.update_url,
		use_ipv6 = V.use_ipv6,
		use_syslog = V.use_syslog,
		use_https = V.use_https,
		force_interval = V.force_interval,
		force_unit = V.force_unit,
		ip_source = V.ip_source,
		ip_interface = V.ip_interface,
		check_interval = V.check_interval,
		check_unit = V.check_unit,
		retry_interval = V.retry_interval,
		retry_unit = V.retry_unit,
		enabled = V.enabled,
		service_name = V.service_name,
		domain = V.domain,
		username = V.username,
		password = V.password
	})

	return
end

function _getDdnsList ()
	local rv = {}

	local fd = io.open('/usr/lib/ddns/services')

	if fd then
		local ln
		repeat
			ln = fd:read('*l')
			local s = ln and ln:match('^%s*"([^"]+)"')
			if s then rv[#rv+1] = s end
		until not ln
		fd:close()
	end

	if #rv == 0 then return nil end
	return rv
end

function getDdnsList ()
	local rv = {}
	local action = _getDdnsList()
	if action then
		rv = action
	end

	if #rv > 0 then
		return code.ok(rv, ddns_options)
	else
		return code.empty('DDNS Service List+', ddns_options)
	end

end

function setDdns ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _setDdns()
	if action then return action end

	uci:commit("ddns")

	getDdns()

	luci.sys.exec("/etc/init.d/ddns restart")
end

function setDdnsPower ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _setDdnsPower()
	if action then return action end

	-- getDdns()
	-- No real-time refresh UCI Config

	local list = _getDdns()

	for index, item in ipairs(list) do
		if PBUtil.getFormValue({ 'wname' }).wname == item.wname then
			list[index].enabled = PBUtil.getFormValue({ 'enabled' }).enabled
		end
	end

	if list then
		code.ok(list, ddns_options)
	else
		code.empty("DDNS+", ddns_options)
	end

	luci.sys.exec("/etc/init.d/ddns restart")
end
