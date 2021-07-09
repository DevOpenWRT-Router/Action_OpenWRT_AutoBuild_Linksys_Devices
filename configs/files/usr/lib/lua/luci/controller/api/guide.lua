local PBUCI = require "luci.pb.PBUCI"
local PBUtil = require "luci.pb.PBUtil"
local code = PBUtil.message()
local checker = require 'luci.pb.checker'
local lan = require 'luci.controller.api.lan'
local uci = require('luci.model.uci').cursor()
local wifi = require 'luci.controller.api.wifi'
local sys = require 'luci.controller.api.sys'

local version = '0.0.4'
local version_num = 4

local guide_options = {version = version, version_num = version_num}

module('luci.controller.api.guide', package.seeall)

function index ()
	local page   = node('api', 'guide')
	page.target  = firstchild()
	page.title   = nil
	page.order   = 300
	page.sysauth = false
	page.ucidata = true
	page.index = true

	entry({'api', 'guide', 'status'}, call('getStatus'), nil, 0)
	entry({'api', 'guide', 'wan'}, call('setWan'), nil, 10)
	entry({'api', 'guide', 'wan.proto'}, call('getWanProto'), nil, 11)
	entry({'api', 'guide', 'lan'}, call('setLan'), nil, 20)
	entry({'api', 'guide', 'wifi'}, call('setWifi'), nil, 30)

	entry({'api', 'guide', 'password'}, call('setAdminPwd'), nil, 40)
	entry({'api', 'guide', 'lang'}, call('setSysLang'), nil, 40)

	entry({'api', 'guide', 'finish'}, call('finish'), nil, 90)
	entry({'api', 'guide', 'skip'}, call('skip'), nil, 95)
end

function getStatus ()
	local isGuide = PBUtil.getUCISection('user', 'sys', 'guide') or '0'
	return code.ok({{
		isGuide = isGuide
	}}, guide_options)
end

--[[
	检查当前状态

	@since 0.1.0

	@return {String} if not to guide
--]]
function checkStatus ()
	local isGuide = PBUtil.getUCISection('user', 'sys', 'guide')
	if isGuide == 0 or isGuide == '0' then
		return code.error('Guide+', guide_options)
	end
	return nil
end

function setWan ()
	if checkStatus() then return end
	local action = _setWan()
	if action then return action end

	uci:commit('network')
	uci:commit('user')

	return code.ok(nil, guide_options)
end

--[[
	检测WAN口类型

	@since 0.1.0

	@return {String}
--]]
function getWanProto ()
	if checkStatus() then return end

	local proto = require('luci.controller.api.wan')._getWanProto()
	if proto:match('%D') then return end

	return code.ok({{
		proto = tonumber(proto)
	}}, guide_options)
end

function setLan ()
	if checkStatus() then return end

	return code.ok(nil, guide_options)
end

function setWifi ()
	if checkStatus() then return end

	local action = wifi._setWifi()
	if action then return action end

	uci:commit('wireless')
	uci:commit('network')

	return code.ok(nil, guide_options)
end

--[[
	设置管理密码

	@param {String} username [可选]
	@param {String} password
	@since 0.1.0
--]]
function setAdminPwd ()
	if checkStatus() then return end

	local V = PBUtil.getFormValue({
		'username', 'password'
	})

	if not V.username then
		V.username = 'root'
	end

	if not V.password then
		return code.error('Password+', guide_options)
	end

	local function login ()
		local util = require "luci.util"
		local http = require "luci.http"
		if luci.sys.user.checkpasswd(V.username, V.password) then
			local rv = {}
			rv.user = V.username
			local sdat = util.ubus("session", "create", { timeout = tonumber(luci.config.sauth.sessiontime) })
			if sdat then
				token = luci.sys.uniqueid(16)
				util.ubus("session", "set", {
					ubus_rpc_session = sdat.ubus_rpc_session,
					values = {
						user = V.username,
						token = token,
						section = luci.sys.uniqueid(16)
					}
				})
				sess = sdat.ubus_rpc_session
			end
			if sess and token then
				rv.date = os.time()
				rv.limit = luci.config.sauth.sessiontime
				rv.sysauth = sess
				http.header("Set-Cookie", 'sysauth=%s; path=%s' %{ sess, luci.dispatcher.build_url() })
			end
			if sess and token then
				return code.ok({ rv }, guide_options)
			else
				return code.error('Password+', guide_options)
			end
		end
	end

	-- When it is old administra password
	if login() then return end

	if luci.sys.user.setpasswd(V.username, V.password) ~= 0 then
		return code.error('Username Or Password+', guide_options)
	end

	-- When it is new administra password
	if login() then return end

	return code.code40010('guide.lua -> setAdminPwd+', guide_options)
end

--[[
	设置系统语言

	@param {String} lang
	@since 0.1.0
--]]
function setSysLang ()
	if checkStatus() then return end

	local lang = luci.http.formvalue('lang') or nil

	if not lang then
		return code.error('Lang+', guide_options)
	else
		uci:set('luci', 'main', 'lang', lang)
		uci:set("user", "sys", "lang", lang)

		uci:commit('luci')
		uci:commit("user")
		return code.ok({{
				lang = lang
			}}, guide_options)
	end

	return code.code40010('guide.lua -> setSysLang+', guide_options)
end

function finish ()
	if checkStatus() then return end

	uci:commit('wireless')
	uci:commit('network')

	skip()

	-- luci.sys.exec('ubus call network reload')
	luci.sys.exec("wifi down;wifi up")
	luci.sys.exec('/etc/init.d/network restart')
end

function skip ()
	uci:set('user', 'sys', 'guide', 0)

	uci:commit('user')

	return sys.getInfo()
end

function _setWan ()
	local proto = luci.http.formvalue('proto') or nil
	if not proto then
		return code.miss('Proto+', guide_options)
	end
	-- PPPoe
	if proto == 'pppoe' then
		local username = luci.http.formvalue('username') or nil
		local password = luci.http.formvalue('password') or nil
		if not username then
			return code.miss('Username+', guide_options)
		end
		if not password then
			return code.miss('Password+', guide_options)
		end
		uci:set('network', 'wan', 'proto', 'pppoe')
		uci:set('network', 'wan', 'username', username)
		uci:set('network', 'wan', 'password', password)
		uci:set('user', 'wan', 'username', username)
		uci:set('user', 'wan', 'password', password)
	end
	-- DHCP
	if proto == 'dhcp' then
		uci:set('network', 'wan', 'proto', 'dhcp')
	end
	-- Static IP
	if proto == 'static' then
		local ipaddr = luci.http.formvalue('ipaddr') or nil
		local subnet = luci.http.formvalue('subnet') or nil
		local gateway = luci.http.formvalue('gateway') or nil
		if not ipaddr then
			return code.miss('Ipaddr+', guide_options)
		end
		if not subnet then
			return code.miss('Subnet+', guide_options)
		end
		if not gateway then
			return code.miss('Gateway+', guide_options)
		end
		if not checker.ipv4(ipaddr) then
			return code.error('Ipaddr+', guide_options)
		end
		if not checker.ipv4(subnet) then
			return code.error('Subnet+', guide_options)
		end
		if not checker.ipv4(gateway) then
			return code.error('Gateway+', guide_options)
		end
		uci:set('network', 'wan', 'proto', 'static')
		if ipaddr then
			uci:set('network', 'wan', 'ipaddr', ipaddr)
			uci:set('user', 'wan', 'ipaddr', ipaddr)
		end
		if subnet then
			uci:set('network', 'wan', 'subnet', subnet)
			uci:set('user', 'wan', 'subnet', subnet)
		end
		if gateway then
			uci:set('network', 'wan', 'gateway', gateway)
			uci:set('user', 'wan', 'gateway', gateway)
		end
	end

	return nil;
end
