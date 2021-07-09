local uci       = require("luci.model.uci").cursor()
local base      = require "luci.controller.api.index"
local PBCommand = require "luci.pb.PBCommand"
local PBUCI     = require "luci.pb.PBUCI"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()
local checker   = PBUtil.checker()

module("luci.controller.api.wan", package.seeall)

function index ()
	local page   = node("api", "wan")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 300
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "wan", "status"}, call("getWan"), nil,10)
	entry({"api", "wan", "inspect"}, call("action_inspect"), nil, 15)
	entry({"api", "wan", "proto"}, call("getWanProto"), nil,16)
	entry({"api", "wan", "setter"}, call("setWan"), nil,20)
	entry({"api", "wan", "mac"}, call("setMac"), nil,30)
end

function _getWan ()
	local wan = PBUCI.getUCISection('network', 'wan')
	wan = PBUtil.mergeTable(wan, PBUCI.getUCISection('network', 'wan_dev') or {})
	wan.ifname = nil

	if wan.proto ~= 'pppoe' then
		wan.username = PBUCI.getUCISection('user', 'wan', 'username') or nil
		wan.password = PBUCI.getUCISection('user', 'wan', 'password') or nil
	end


	if PBUCI.getUCISection('user', 'sys', 'expert') == '1' then
		wan.mtu = wan.mtu or '0'
		-- 0: Custom  1: Auto
		wan.peerdns = wan.peerdns or '1'
		if wan.peerdns == '0' then
			wan.dns = {}
			for _, value in ipairs(PBUCI.getUCISection('network', 'wan', 'dns'):split(' ')) do
				wan.dns[#wan.dns+1] = value
			end
		end
	end
	if PBUCI.getUCISection('user', 'sys', 'expert') ~= '1' then
		wan.mtu = nil
		wan.peerdns = nil
		wan.dns = nil
	end

	-- Mac
	wan.mac_clone  = PBUCI.getUCISection('user', 'wan', 'mac_clone') or '0'
	wan.macoldaddr = PBUCI.getUCISection('user', 'wan', 'macaddr') or nil

	if base.checkAuth() then
		local ntm = require "luci.model.network".init()
		local wannet = ntm:get_wannet()
		if wannet then
			wan.status = {
				ipaddr  = wannet:ipaddr(),
				gwaddr  = wannet:gwaddr(),
				netmask = wannet:netmask(),
				dns     = wannet:dnsaddrs(),
				expires = wannet:expires(),
				uptime  = wannet:uptime(),
				proto   = wannet:proto(),
			}
		end
	end

	if not base.checkAuth() then
		wan.username = nil
		wan.password = nil
		wan.macaddr  = nil
		if wan.proto ~= 'static' then
			wan.dns = nil
		end
	end

	return wan
end

function getWan ()
	local wan = _getWan()
	local rv = {}
	-- Import
	rv[#rv+1] = wan
	if #rv > 0 then
		return code.code0(rv)
	else
		return code.code40003("Wan+")
	end
	code.code40010("wan.lua->getWan+");
end

function _getWanProto ()
	local appOldPath = '/usr/bin/detect_wan'
	local appNewPath = '/usr/bin/wan_discovery'
	local appPath = ''
	if nixio.fs.access(appOldPath) then
		appPath = appOldPath
	end
	if nixio.fs.access(appNewPath) then
		appPath = appNewPath
	end
	if appPath == ''  then
		return code.code40003('Miss wan check tool', guide_options)
	end

	if appPath == appNewPath then
		local wan = PBUCI.getUCISection('network', 'wan') or { }
		if not wan.ifname then
			return code.code40003('Miss wan ifname', guide_options)
		end
		appPath = appPath .. ' '.. wan.ifname
	end

	local appPipe = ' >/dev/null 2>/dev/null;'

	local rv = PBCommand.get(appPath .. appPipe .. 'echo $?')

	if rv[#rv]:match('%D') then
		return code.code40003('Return INFO Error', guide_options)
	end

	return rv[#rv]
end

function getWanProto ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local proto = _getWanProto()
	if proto:match('%D') then return end

	return code.ok({{
		proto = tonumber(proto)
	}}, guide_options)
end

function action_speedtest ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end
	if not nixio.fs.access('/usr/bin/speedtest') then
		return code.code40003('Miss speedtest', guide_options)
	end

	local rv = PBCommand.get('/usr/bin/speedtest')

	if rv[#rv]:match('%d') then
		local obj = {
			base     = { },
			location = { },
			speed    = { }
		}

		obj.base.ip, obj.base.isp =
			rv[1]:match('(%d+%.%d+%.%d+%.%d+).-ISP:%s(.*)')

		obj.speed.download, obj.speed.upload = rv[#rv]:match('(%d+).-(%d+)')
		obj.speed.download                   = tonumber(obj.speed.download)
		obj.speed.upload                     = tonumber(obj.speed.upload)

		obj.location.lat, obj.location.lon =
			rv[2]:match('(%d+%.%d+).-(%d+%.%d+)')
		obj.location.name, obj.location.country,
		obj.location.sponsor, obj.location.dist =
			rv[5]:match('Name:(.-) Country: (.-) Sponsor: (.-) Dist: (%d+)')

		return code.ok({ obj })
	else
		return code.ok({{ error = 1 }})
	end
end

function action_inspect ()
	local V = PBUtil.getFormValue({
		'_method', 'type'
	})
	if not V['_method'] then
		return code.miss('Method+')
	elseif 'string' ~= type(V['_method']) then
		return code.error('Method+')
	else
		V['_method'] = V['_method']:upper()
	end
	if not V['type'] then
		return code.miss('Type+')
	end
	if 'GET' == V['_method'] then
		-- Speed Test
		if 'speedtest' == V['type'] then
			return action_speedtest()
		end
		-- Proto Test
		if 'prototest' == V['type'] then
			return getWanProto()
		end
	end
end

function _setWan ()
	local proto = luci.http.formvalue("proto") or nil
	if not proto then
		return code.code40001("Proto+")
	end
	local mtu = luci.http.formvalue("mtu") or nil
	if mtu then
		if type(mtu) ~= 'string' or
			string.len(mtu) == 0 or
			mtu:match('%D') then
			return code.code40002("Mtu+")
		end
		-- 最少值由Lintel 提供
		-- Lintel 说, 少于512就没有意义了
		if tonumber(mtu) > 1500 or tonumber(mtu) < 512 then
			return code.code40002("Mtu+")
		end
	end

	local peerdns = luci.http.formvalue("peerdns") or nil
	local dns = luci.http.formvalue("dns") or nil
	if peerdns then
		if peerdns:match('%D') then
			return code.code40002('PeerDNS+')
		end
		if peerdns ~= '0' and peerdns ~= '1' then
			return code.code40002('PeerDNS+')
		end
		if peerdns == '0' and not dns then
			return code.code40001('DNS+')
		end
	end
	if peerdns == '0' and dns then
		if type(dns) ~= 'string' and type(dns) ~= 'table' then
			return code.code40002('DNS+')
		end
		if type(dns) == 'string' then
			if not checker.ipv4(dns) then
				return code.code40002('DNS+')
			end
			if dns:match('%.0$') or
				dns:match('255$') then
				return code.code40002('DNS+')
			end
		end
		if type(dns) == 'table' then
			for _, value in ipairs(dns) do
				if not checker.ipv4(value) then
					return code.code40002('DNS+')
				end
				if value:match('%.0$') or
					value:match('255$') then
					return code.code40002('DNS+')
				end
			end
		end
	end

	if mtu then
		if proto == 'pppoe' and tonumber(mtu) > 1492 then
			mtu = '1492'
		elseif tonumber(mtu) > 1500 then
			mtu = '1500'
		end
		uci:set('network', 'wan', 'mtu', mtu)
		if tonumber(mtu) == 0 then
			 PBUCI.removeSection("network", "wan", "mtu")
		end
	end
	if peerdns then
		uci:set('network', 'wan', 'peerdns', peerdns)
		if peerdns == '0' then
			local _dns = ''
			if type(dns) == 'string' then
				_dns = dns
			end
			if type(dns) == 'table' then
				for _, value in ipairs(dns) do
					if string.len(_dns) ~= 0 then
						_dns = _dns .. ' '
					end
					_dns = _dns .. value
				end
			end
			uci:set('network', 'wan', 'dns', _dns)
		end
	end
	-- PPPoe
	if proto == 'pppoe' then
		local username = luci.http.formvalue("username") or nil
		local password = luci.http.formvalue("password") or nil
		local service  = luci.http.formvalue("service") or nil
		if not username then
			return code.code40001("Username+")
		end
		if not password then
			return code.code40001("Password+")
		end
		PBUCI.setUCISection('network', 'wan', {
			proto    = proto,
			username = username,
			password = password
		})
		if service then
                        PBUCI.setUCISection('network', 'wan', {
                                service  = service
                        })
		elseif PBUCI.getUCISection("network", "wan", "service") then
			PBUCI.delUCISection("network", "wan", "service")
		end
		PBUCI.setUCISection('user', 'wan', {
			username = username,
			password = password
		})
	end
	-- DHCP
	if proto == 'dhcp' then
		uci:set("network", "wan", "proto", "dhcp")
	end
	-- Static IP
	if proto == 'static' then
		local V = PBUtil.getFormValue({
			'ipaddr', 'netmask', 'gateway'
		})
		for _, item in ipairs(V) do
			if not V[item] then
				return code.miss(item .. "+")
			end
			if not checker.ipv4(V[item]) then
				return code.error(item .. "+")
			end
		end
		PBUCI.setUCISection('network', 'wan', {
			proto   = 'static',
			ipaddr  = V.ipaddr,
			netmask = V.netmask,
			gateway = V.gateway
		})
		PBUCI.setUCISection('user', 'wan', {
			ipaddr  = V.ipaddr,
			netmask = V.netmask,
			gateway = V.gateway
		})
	else
		PBUCI.removeUCISection('network', 'wan', {
			'ipaddr', 'netmask', 'gateway'
		})
	end

	return nil;
end

function setWan ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _setWan()
	if action then return action end

	uci:commit("network")
	uci:commit("user")

	getWan()

	luci.sys.exec("ubus call network reload")
	luci.sys.exec("ifup wan")
end

function setMac ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

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

	local wan = _getWan()
	if wan.macaddr == macaddr then
		return code.code60001();
	end

	uci:set("user", "wan", "mac_clone", mac_clone)
	if (mac_clone == "1" or mac_clone == 1) and not wan.macoldaddr then
		uci:set("user", "wan", "macaddr", wan.macaddr)
	end
	uci:set("network", "wan_dev", "macaddr", macaddr);

	uci:commit("network")
	uci:commit("user")

	getWan()

	luci.sys.exec("ubus call network reload")
	luci.sys.exec("/etc/init.d/network restart")
end
