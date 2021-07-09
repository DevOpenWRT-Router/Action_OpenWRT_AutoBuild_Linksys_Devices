local uci       = require("luci.model.uci").cursor()
local base      = require "luci.controller.api.index"
local PBUCI     = require "luci.pb.PBUCI"
local PBCommand = require "luci.pb.PBCommand"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()
local checker   = require "luci.pb.checker"

module("luci.controller.api.lan", package.seeall)

function index ()
	local page   = node("api", "lan")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 300
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "lan", "status"}, call("getLan"), nil, 10)
	entry({"api", "lan", "setter"}, call("setLan"), nil, 11)
	entry({"api", "lan", "power"}, call("action_power"), nil, 15)
	entry({"api", "lan", "mac"}, call("setMac"), nil, 20)
	-- clients
	entry({"api", "lan", "clients"}, call("getDhcpClients"), nil, 30)
	entry({"api", "lan", "count"}, call("getDhcpCount"), nil, 31)
	entry({"api", "lan", "clients_6"}, call("getDhcp6Clients"), nil, 32)
	entry({"api", "lan", "count_6"}, call("getDhcp6Count"), nil, 33)
end

function _getLan ()
	local lan = PBUCI.getUCISection('dhcp', 'lan') or {}
	lan = PBUtil.mergeTable(lan, PBUCI.getUCISection('network', 'lan') or {})
	lan = PBUtil.mergeTable(lan, PBUCI.getUCISection('network', 'lan_dev') or {})
	-- DHCP
	lan.ignore = lan.ignore or 0
	lan.start  = lan.start or ""
	lan.limit  = lan.limit or ""
	if PBUCI.getUCISection('user', 'sys', 'expert') ~= "1" then
		lan.leasetime = nil
	end
	-- IP
	lan.ip = lan.ipaddr
	-- Mac
	local user = PBUCI.getUCISection('user', 'lan') or {}
	user.macoldaddr = user.macaddr or nil
	lan = PBUtil.mergeTable(lan, user)
	return lan
end

function getLan ()
	local lan = _getLan()
	local rv  = {}
	-- Import
	rv[#rv+1] = lan
	if #rv > 0 then
		return code.code0(rv)
	else
		return code.code40003("Lan+")
	end
	return code.code40010("lan.lua->getLan+")
end

function _setLan ()
	local V = PBUtil.getFormValue({
		"ipaddr",
		"netmask",
		"start",
		"limit",
		"ignore",
		"leasetime"
	})

	if V.ipaddr then
		local CheckList = { 'ipaddr' }
		if V.netmask then
			CheckList[#CheckList+1] = 'netmask'
		end
		for _, item in ipairs(CheckList) do
			if not checker.ipv4(V[item]) then
				return code.error(item .. '+')
			end
			if V[item] == "0.0.0.0" then
				return code.error(item .. '+')
			end
		end
		PBUCI.setUCISection('network', 'lan', {
			ipaddr = V.ipaddr,
			netmask = V.netmask
		})
	elseif V.start or V.limit then
		local CheckList = { 'start', 'limit' }
		for _, item in ipairs(CheckList) do
			if not V[item] then
				return code.miss(item .. '+')
			end

			-- Start and Limit Check
			if type(V[item]) ~= 'string' or
				V[item]:match("%D") or
				string.len(V[item]) == 0 then
				return code.error(item .. '+')
			end

			local _item = tonumber(V[item])
			if _item < 0 or _item > 255 then
				return code.error("Start+")
			end
		end

		-- Lease Time Check
		if V.leasetime then
			if not V.leasetime:match('^%d+m$') and
				not V.leasetime:match('^%d+h$') then
				return code.code40002("Leasetime+")
			end
			local _leasetime = tonumber(V.leasetime:match('^%d+'))
			if V.leasetime:match('m') then
				if _leasetime < 2 then V.leasetime = '2m' end
				if _leasetime > 4320 then V.leasetime = '4320m' end
			end
			if V.leasetime:match('h') then
				if _leasetime < 0 then V.leasetime = '1h' end
				if _leasetime > 72 then V.leasetime = '72h' end
			end
		end

		PBUCI.setUCISection('dhcp', 'lan', {
			start     = V.start,
			limit     = V.limit,
			leasetime = V.leasetime
		})
	end

	if V.ignore then
		if not V.ignore then
			return code.miss('Ignore+')
		end

		-- Power Check
		if V.ignore ~= "0" and V.ignore ~= "1" then
			return code.error("Ignore+")
		end
		PBUCI.setUCISection('network', 'lan', {
			ignore = ignore
		})
	end
end

function setLan ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		"ipaddr",
		"netmask",
		"start",
		"limit",
		"ignore",
		"leasetime"
	})
	if not (V.ipaddr or V.start or V.limit or V.ignore) then
		return code.code40001("Every+")
	end

	local action = _setLan()
	if action then return action end

	getLan()

	local data = _getLan()
	if V.ipaddr then
		if V.ipaddr == data.ipaddr and
			V.netmask and netmask == data.netmask then
			return
		end
		PBCommand.run("reboot")
	elseif V.start and V.limit then
		if V.start == data.start and
			V.limit == data.limit then
			if not V.leasetime then
				return
			elseif V.leasetime == data.leasetime then
				return
			end
		end
		PBCommand.run({
			"ubus call network reload",
			"/etc/init.d/network restart",
			"/etc/init.d/dnsmasq restart"
		})
	end
end

--[[
	设置DHCP 开关信息

	@since 0.3.0
	@param {String|Number} ignore
	@param {String} sysauth
	@param {String} stok

	@return {String} ErrorInfo
--]]
function _setDhcpPower ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local ignore = PBUtil.getFormValue({
		'ignore'
	}).ignore or nil

	if not ignore then
		return code.code40001('Ignore+')
	end
	if type(ignore) ~= 'string' or string.len(ignore) == 0 then
		return code.code40002('Ignore+')
	end
	if ignore:match('%D') then
		return code.code40002('Ignore+')
	end
	ignore = ignore:match('%d+')
	if tonumber(ignore) < 0 or
		tonumber(ignore) > 1 then
		return code.code40002('Ignore+')
	end

	-- Setter

	if PBUCI.setUCISection('dhcp', 'lan', {
		ignore = ignore
	}) then PBCommand.run({
		"ubus call network reload",
		"/etc/init.d/network restart"
	}) end
end

--[[
	DHCP

	@since 0.3.0

	@return {Array}
--]]
function _getDhcpPower ()
	local rv  = {}

	rv.ignore = uci:get('dhcp', 'lan', 'ignore') or '1'

	return {rv}
end

--[[
	获取/设置DHCP 开关信息

	@see _getDhcpPower()
	@see _setDhcpPower()
	@since 0.3.0
--]]
function action_power ()
	local ignore = luci.http.formvalue('ignore') or nil

	if ignore then
		local action = _setDhcpPower()
		if action then return end
	end

	local rv = _getDhcpPower()
	if #rv > 0 then
		return code.code0(rv)
	else
		return code.code40003("DHCP Power+")
	end
end

function setMac ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local lan = _getLan()

	local mac_clone = luci.http.formvalue("mac_clone") or nil
	local macaddr = luci.http.formvalue("macaddr") or nil

	if not mac_clone then
		return code.code40001("Mac_clone+")
	end
	if not (mac_clone == "0" or mac_clone == "1" or
		mac_clone == 0 or mac_clone == 1) then
		return code.code40002("Mac_clone+")
	end
	if not macaddr then
		return code.code40001("Macaddr+")
	end
	if not checker.mac(macaddr) then
		return code.code40002("Macaddr+")
	end
	if macaddr == '00:00:00:00:00:00' or
	 	macaddr == 'ff:ff:ff:ff:ff:ff' or
	 	macaddr:match('^33:33:') or
	 	macaddr:match('^01:80:c2:') or
	 	macaddr:match('^01:00:5e:') then
		return code.code40002("Macaddr+")
	end

	if lan.macaddr == macaddr then
		return code.code60001();
	end

	uci:set("user", "lan", "mac_clone", mac_clone)
	if (mac_clone == "1" or mac_clone == 1) and not lan.macoldaddr then
		uci:set("user", "lan", "macaddr", lan.macaddr)
	end
	uci:set("network", "lan_dev", "macaddr", macaddr);

	uci:commit("network")
	uci:commit("user")

	getLan()

	PBCommand.run({
		"ubus call network reload",
		"/etc/init.d/network restart"
	})
end

-- Copy from `base\luasrc\tools\status.lua`
local function _dhcpLeasesCommon(family)
	local rv        = { }
	local nfs       = require "nixio.fs"
	local leasefile = "/var/dhcp.leases"

	uci:foreach("dhcp", "dnsmasq",
		function(s)
			if s.leasefile and nfs.access(s.leasefile) then
				leasefile = s.leasefile
				return false
			end
		end)

	local fd = io.open(leasefile, "r")
	if fd then
		while true do
			local ln = fd:read("*l")
			if not ln then
				break
			else
				local ts, mac, ip, name, duid = ln:match("^(%d+) (%S+) (%S+) (%S+) (%S+)")
				if ts and mac and ip and name and duid then
					if family == 4 and not ip:match(":") then
						rv[#rv+1] = {
							expires  = os.difftime(tonumber(ts) or 0, os.time()),
							macaddr  = mac,
							ipaddr   = ip,
							hostname = (name ~= "*") and name
						}
					elseif family == 6 and ip:match(":") then
						rv[#rv+1] = {
							expires  = os.difftime(tonumber(ts) or 0, os.time()),
							ip6addr  = ip,
							duid     = (duid ~= "*") and duid,
							hostname = (name ~= "*") and name
						}
					end
				end
			end
		end
		fd:close()
	end

	local fd = io.open("/tmp/hosts/odhcpd", "r")
	if fd then
		while true do
			local ln = fd:read("*l")
			if not ln then
				break
			else
				local iface, duid, iaid, name, ts, id, length, ip = ln:match("^# (%S+) (%S+) (%S+) (%S+) (%d+) (%S+) (%S+) (.*)")
				if ip and iaid ~= "ipv4" and family == 6 then
					rv[#rv+1] = {
						expires  = os.difftime(tonumber(ts) or 0, os.time()),
						duid     = duid,
						ip6addr  = ip,
						hostname = (name ~= "-") and name
					}
				elseif ip and iaid == "ipv4" and family == 4 then
					rv[#rv+1] = {
						expires  = os.difftime(tonumber(ts) or 0, os.time()),
						macaddr  = duid,
						ipaddr   = ip,
						hostname = (name ~= "-") and name
					}
				end
			end
		end
		fd:close()
	end

	return rv
end

-- Copy from `base\luasrc\tools\status.lua`
function _dhcpLeases()
	return _dhcpLeasesCommon(4)
end

-- Copy from `base\luasrc\tools\status.lua`
function _dhcp6Leases()
	return _dhcpLeasesCommon(6)
end

function getDhcpClients ()
	local action = _dhcpLeases()
	if #action == 0 then
		return code.code40003("DHCP Client+")
	else
		return code.code0(action)
	end
	return code.code40010("Lan.lua->getDhcpClients+")
end

function getDhcp6Clients ()
	local action = _dhcp6Leases()
	if #action == 0 then
		return code.code40003("DHCP6 Client+")
	else
		return code.code0(action)
	end
	return code.code40010("Lan.lua->getDhcp6Clients+")
end

function getDhcpCount ()
	local rv = {{
		count = #_dhcpLeases()
	}}
	return code.code0(rv)
end

function getDhcp6Count ()
	local rv = {{
		count = #_dhcp6Leases()
	}}
	return code.code0(rv)
end
