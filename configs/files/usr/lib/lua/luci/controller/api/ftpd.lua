local uci       = require('luci.model.uci').cursor()
local base      = require 'luci.controller.api.index'
local PBCommand = require "luci.pb.PBCommand"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()

local version     = '0.2.0'
local version_num = 3

local ftpd_options = {version = version, version_num = version_num}

module('luci.controller.api.ftpd', package.seeall)

function index ()
	local page   = node('api', 'ftpd')
	page.target  = nil
	page.title   = nil
	page.order   = 432
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({'api', 'ftpd', 'status'}, call('action_status'), nil, 0)

	entry({'api', 'ftpd', 'setter'}, call('action_setter'), nil, 5)
	entry({'api', 'ftpd', 'power'}, call('action_switch'), nil, 6)
	-- entry({'api', 'ftpd', 'delete'}, call('action_delete'), nil, 10)
end

--[[
	获取模块状态

	@since 0.1.2
	@return {Boolean} Status
--]]
function moduleStatus ()
	if not nixio.fs.access("/etc/init.d/vsftpd") then
		return false
	end
	if not nixio.fs.access("/etc/config/vsftpd") then
			return false
	end
	return true
end


--[[
	获取FTP 信息

	@since 0.1.2

	@return {Array}
--]]
function action_status ()
	local rv = PBUtil.getUCISection('vsftpd', 'main')
	return code.ok({ rv }, ftpd)
end

function _setFtp ()
	local V = PBUtil.getFormValue({
		'enabled', 'local_enable', 'write_enable', 'chown_uploads',
		'local_umask', 'anonymous_enable', 'max_clients', 'userlist_type',
		'userlist', 'ftpd_banner', 'ascii', 'idle_session_timeout',
		'data_connection_timeout', 'connect_from_port_20', 'async_abor_enable',
		'ls_recurse_enable', 'dirmessage_enable', 'userlist_enable',
		'anon_root', 'chroot_local_user'
	})

	--[[
		Checker
	--]]
	if V == {} then
		return code.miss('Any+', ftpd_options)
	end
	-- Enabled Class
	for _, item in ipairs({ 'enabled', 'local_enable', 'write_enable', 'chown_uploads',
		'anonymous_enable', 'connect_from_port_20', 'async_abor_enable',
		'ls_recurse_enable', 'dirmessage_enable', 'userlist_enable',
		'chroot_local_user' }) do
		if V[item] then
			if V[item]:match('[%D2-9]') then
				local function getErrorTextHead (text)
					return text:gsub('^.', text:match('^.'):upper())
				end
				return code.error(getErrorTextHead(item) .. '+', ftpd_options)
			end
		end
	end

	-- Number Class
	for _, item in ipairs({'local_umask', 'max_clients', 'idle_session_timeout',
		'data_connection_timeout'}) do
		if V[item] then
			if V[item]:match('%D') or V == '0' then
				local function getErrorTextHead (text)
					return text:gsub('^.', text:match('^.'):upper())
				end
				return code.error(getErrorTextHead(item) .. '+', ftpd_options)
			end
		end
	end

	if V.anon_root then
		if V.anon_root:match('%.%.') then
			return code.error('Anon_Root+', ftpd_options)
		end
	end

	--[[
		Setter
	--]]
	local isSuc = PBUtil.setUCISection('vsftpd', 'main', {
		enabled                 = V.enabled,
		local_enable            = V.local_enable,
		write_enable            = V.write_enable,
		chown_uploads           = V.chown_uploads,
		local_umask             = V.local_umask,
		anonymous_enable        = V.anonymous_enable,
		max_clients             = V.max_clients,
		userlist_type           = V.userlist_type,
		userlist                = V.userlist,
		ftpd_banner             = V.ftpd_banner,
		ascii                   = V.ascii,
		idle_session_timeout    = V.idle_session_timeout,
		data_connection_timeout = V.data_connection_timeout,
		connect_from_port_20    = V.connect_from_port_20,
		async_abor_enable       = V.async_abor_enable,
		ls_recurse_enable       = V.ls_recurse_enable,
		dirmessage_enable       = V.dirmessage_enable,
		userlist_enable         = V.userlist_enable,
		anon_root               = V.anon_root,
		chroot_local_user       = V.chroot_local_user
	})

	if isSuc then PBCommand.run('/etc/init.d/vsftpd restart') end
	return
end

--[[
	设置FTP 信息

	@since 0.1.2

	@return {Array}
--]]
function action_setter ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local action = _setFtp ()
	if action then return action end

	return action_status()
end

function action_switch ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({ 'enabled' })
	if not V.enabled then
		return code.miss('Enabled+', ftpd_options)
	end

	local action = _setFtp ()
	if action then return action end

	return action_status()
end

-- function action_delete ()
-- end
