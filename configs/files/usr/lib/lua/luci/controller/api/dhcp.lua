local uci    = require("luci.model.uci").cursor()
local base   = require "luci.controller.api.index"
local PBUtil = require "luci.pb.PBUtil"
local code   = PBUtil.message()

local version     = '0.1.0'
local version_num = 3

local dhcp_options = {version = version, version_num = version_num}

module("luci.controller.api.dhcp", package.seeall)

function index ()
	local page   = node("api", "dhcp")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 430
	page.sysauth = false
	page.ucidata = true
	page.index   = true


	entry({"api", "dhcp", "status"}, call("getDhcp"), nil, 0)
	entry({"api", "dhcp", "getter"}, call("getDhcp"), nil, 10)
	entry({"api", "dhcp", "setter"}, call("setDhcp"), nil, 20)
	entry({"api", "dhcp", "delete"}, call("deleteDhcp"), nil, 30)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/dhcp") then
		return false
	end

	return true
end

function _getDhcp ()
	local list = PBUtil.getUCIList('dhcp', 'host')

	for _, host in ipairs(list) do
		host.ipaddr  = host.ip or nil
		host.macaddr = host.mac or nil
	end

	return list
end

function getDhcp ()
	local rv = _getDhcp() or {}

	if #rv == 0 then
		return code.empty("DHCP Static IP+", dhcp_options)
	end
	if rv then
		return code.ok(rv, dhcp_options)
	end
end

function setDhcp ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		"wname", "name", "macaddr", "ipaddr"
	})
	V.ip  = V.ipaddr or nil
	V.mac = V.macaddr or nil

	local wname  = nil
	local _wname = luci.http.formvalue("wname") or nil

	if not V.name then
		return code.miss("Name+", dhcp_options)
	end
	if not V.macaddr then
		return code.miss("Macaddr+", dhcp_options)
	end
	if not V.ipaddr then
		return code.miss("Ipaddr+", dhcp_options)
	end

	V.wname = PBUtil.checkWname(V.wname, 'dhcp', 'host')

	if not V.wname then
		V.wname = uci:add("dhcp", "host")
		uci:commit('dhcp')
	end

	local isSuc = PBUtil.setUCISection('dhcp', V.wname, {
		name = V.name,
		ip   = V.ip,
		mac  = V.mac
	})

	uci:commit('dhcp')

	getDhcp()

	if isSuc then luci.sys.exec("/etc/init.d/dnsmasq restart") end
end

function _deleteDhcp ()
	local V = PBUtil.getFormValue({
		'wname'
	})
	if not V.wname then
		return code.miss('Wname+', dhcp_options)
	end

	V.wname = PBUtil.checkWname(V.wname, 'dhcp', 'host')

	if not V.wname then
		return code.code40004(nil, dhcp_options)
	end

	uci:delete('dhcp', V.wname)
	uci:commit('dhcp')

	return
end

function deleteDhcp ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _deleteDhcp()
	if action then return action end

	-- getDhcp()
	local list = _getDhcp()
	if #list == 0 then
		return code.empty("DHCP Static IP+", dhcp_options)
	end
	for index, item in ipairs(list) do
		if PBUtil.getFormValue({ 'wname' }).wname == item.wname then
			list[index] = nil
		end
	end

	if #list == 0 then
		return code.empty("DHCP Static IP+", dhcp_options)
	else
		return code.ok(list, dhcp_options)
	end

	luci.sys.exec("/etc/init.d/dnsmasq restart")
end
