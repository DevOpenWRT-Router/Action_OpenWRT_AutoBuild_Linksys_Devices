-- @Author             : Arylo
-- @Date               : 2015-05-29
-- @Last Modified by   : Arylo
-- @Last Modified time : 2016-01-12

local uci       = require("luci.model.uci").cursor()
local base      = require "luci.controller.api.index"
local PBCommand = require "luci.pb.PBCommand"
local PBUCI     = require "luci.pb.PBUCI"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()

local version     = '@@Version'
local version_num = '@@VersionNum'

local dmz_options = { version = version, version_num = version_num }

module("luci.controller.api.dmz", package.seeall)

function index ()
	local page   = node("api", "dmz")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 430
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "dmz", "status"}, call("getDmz"), nil, 0)
	entry({"api", "dmz", "getter"}, call("getDmz"), nil, 10)
	entry({"api", "dmz", "setter"}, call("setDmz"), nil, 20)
	entry({"api", "dmz", "delete"}, call("deleteDmz"), nil, 30)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/firewall") then
		return false
	end
	if not nixio.fs.access("/etc/init.d/firewall") then
		return false
	end

	return true
end

function _getDmz ()
	return PBUtil.getUCIList('firewall', 'redirect')
end

function getDmz ()
	local rv = _getDmz() or {}

	if #rv == 0 then
		return code.empty("DMZ+", dmz_options)
	else
		return code.ok(rv, dmz_options)
	end
	return code.code40010("dmz.lua->getDmz+", dmz_options)
end

function setDmz ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		"wname", "proto", "name",
		"src_dport", "dest_ip", "dest_port",
		"target", "src", "dest"
	})

	V.target = V.target or "DNAT"
	V.src    = V.src or "wan"
	V.dest   = V.dest or "lan"

	for _, item in ipairs({ 'proto', 'src_dport', 'dest_ip',
		'dest_port', 'name' }) do
		if not V[item] then
			return code.miss(item .. '+', dmz_options)
		end
	end

	for _, item in ipairs({ 'src_dport', 'dest_port' }) do
		if V[item]:match('%D') and 'all' ~= V[item] then
			return code.error(item .. '+', dmz_options)
		end
		if V[item]:match('^%d+$') then
			local _item = tonumber(V[item])
			if _item > 65535 then
				return code.error(item .. '+', dmz_options)
			end
		end
	end

	V.wname = PBUtil.checkWname(V.wname, 'firewall', 'redirect')

	if V.wname and
		V.proto     == uci:get("firewall", V.wname, "proto") and
		V.src_dport == uci:get("firewall", V.wname, "src_dport") and
		V.dest_ip   == uci:get("firewall", V.wname, "dest_ip") and
		V.dest_port == uci:get("firewall", V.wname, "dest_port") and
		V.name      == uci:get("firewall", V.wname, "name") then
		return code.code60001(nil, dmz_options)
	end

	if not V.wname then
		PBUCI.getList('firewall', 'redirect'):is({
			proto     = V.proto,
			src_dport = V.src_dport,
			dest_ip   = V.dest_ip,
			dest_port = V.dest_port
		}, function (_, item)
			V.wname = item.wname
		end)
	end

	if not V.wname then
		V.wname = PBUCI.addUCISection("firewall", "redirect")
		-- @XXX
		-- Don't ask me why it's here.
		-- But the lack of it will set the failure.
		uci:commit('firewall')
	end

	local isSuc = PBUtil.setUCISection('firewall', V.wname, {
		target    = V.target,
		proto     = V.proto,
		src       = V.src,
		src_dport = V.src_dport,
		dest      = V.dest,
		dest_ip   = V.dest_ip,
		dest_port = V.dest_port,
		name      = V.name
	})

	uci:commit('firewall')

	getDmz()

	if isSuc then PBCommand.run('/etc/init.d/firewall restart') end
end

function _deleteDmz ()
	local V = PBUtil.getFormValue({
		'wname'
	})
	if not V.wname then
		return code.miss('Wname+', dmz_options)
	end

	V.wname = PBUtil.checkWname(V.wname, 'firewall', 'redirect')

	if not V.wname then
		return code.code40004(nil, dmz_options)
	end

	uci:delete('firewall', V.wname)
	uci:commit('firewall')

	PBCommand.run("/etc/init.d/firewall restart")

	return
end

function deleteDmz ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _deleteDmz()
	if action then return action end

	local list = _getDmz()
	if #list == 0 then
		return code.empty("DMZ+", dmz_options)
	else
		return code.ok(list, dmz_options)
	end
end
