local uci       = require('luci.model.uci').cursor()
local base      = require 'luci.controller.api.index'
local PBCommand = require "luci.pb.PBCommand"
local PBUCI     = require "luci.pb.PBUCI"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()

local version     = '0.2.0'
local version_num = 3

local samba_options = {version = version, version_num = version_num}

module('luci.controller.api.samba', package.seeall)

function index ()
	local page   = node('api', 'samba')
	page.target  = nil
	page.title   = nil
	page.order   = 431
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({'api', 'samba', 'status'}, call('action_status'), nil, 0)

	entry({'api', 'samba', 'setter'}, call('setter'), nil, 5)
	entry({'api', 'samba', 'delete'}, call('delete'), nil, 10)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/samba") then
		return false
	end
	return true
end

--[[
	获取Samba 状态

	@since 0.1.0
	@return {Obeject}
--]]
function getStatus ()
	local tmp = nil
	local rv = {
		sub = { },
		devices = { }
	}

	-- Main Config
	tmp = PBUtil.getUCIList('samba', 'samba')
	if tmp and #tmp > 0 then
		rv = PBUtil.mergeTable(rv, tmp[#tmp])
		rv.enabled = rv.enabled or '1'
	end

	-- Sub Config
	rv.sub = PBUtil.getUCIList('samba', 'sambashare')
	for _, item in ipairs(rv.sub or { }) do
		if uci:get("user", "sys", "expert") ~= "1" then
			item.users       = nil
			item.create_mask = nil
			item.dir_mask    = nil
			item.read_only   = nil
		end
	end

	if #rv.sub == 0 then rv.sub = nil end

	for _, item in ipairs(luci.sys.mounts()) do
		local devPath = item.fs or ''
		for _, reg in ipairs({'\/dev\/sd*', '\/dev\/hd*', '\/dev\/scd*', '\/dev\/mmc*'}) do
			if devPath:match(reg) then
				rv.devices[#rv.devices+1] = item
			end
		end
	end

	return rv
end

--[[
	API: 获取Samba 状态

	@see getStatus()
	@since 0.1.0
--]]
function action_status ()
	local rv = getStatus()

	return code.code0({
		rv
	}, samba_options)
end

--[[
	设置Samba 选项

	@param {String} wname     	[必选]
	@param {String} workgroup	[可选]
	@param {String} description	[可选]
	@param {String} homes		[可选]
	@param {String} autoshare	[可选]
	@param {String} name		[可选]
	@since 0.1.0
	@return @see action_status()
--]]
function setGlobal ()
	local V = PBUtil.getFormValue({
		'wname',
		'enabled',
		'workgroup',
		'description',
		'homes',
		'autoshare',
		'name'
	})
	if not V.wname then
		return code.miss('Wname+', samba_options)
	elseif not PBUtil.checkWname(V.wname, 'samba', 'samba') then
		return code.error('Wname+', samba_options)
	end

	for item in ipairs({ 'name', 'workgroup', 'description' }) do
		if V[item] and string.len(V[item]) then
			return code.error(item .. '+', samba_options)
		end
	end

	for item in ipairs({ 'enabled', 'homes', 'autoshare' }) do
		if V[item] and V[item] ~= '0' and V[item] ~= '1' then
			return code.error(item .. '+', samba_options)
		end
	end

	-- Setter
	local isSuc = PBUtil.setUCISection('samba', V.wname, {
		enabled     = V.enabled,
		workgroup   = V.workgroup,
		description = V.description,
		homes       = V.homes,
		autoshare   = V.autoshare,
		name        = V.name
	})

	uci:commit('samba')

	if isSuc then PBCommand.run('/etc/init.d/samba restart') end

	return action_status()
end

--[[
	设置Samba 目录

	@param {String} wname     	[可选]
	@param {String} name		[可选]
	@param {String} path		[可选]
	@param {String} users		[可选]
	@param {String} guest_ok	[可选]
	@param {String} create_mask	[可选]
	@param {String} dir_mask	[可选]
	@param {String} read_only	[可选]
	@since 0.1.0
	@return @see action_status()
--]]
function setSub ()
	function checkFolderName (name)
		if not name then return nil end
		if string.len(name) == 0 then return nil end
		if name:match('[\\\/:\*\?"<>\|]') or name:match('^ +') then
			return nil
		end
		return name
	end

	local V = PBUtil.getFormValue({
		'name',
		'path',
		'users',
		'guest_ok',
		'create_mask',
		'dir_mask',
		'read_only',
		'wname'
	})

	if V.name and not checkFolderName(V.name) then
		return code.error('Name+', samba_options)
	end
	if V.path and string.len(V.path) == 0 then
		return code.error('Path+', samba_options)
	end
	for item in ipairs({ 'read_only', 'dir_mask' }) do
		if V[item] and (V[item] ~= 'no' and V[item] ~= 'yes') then
			return code.error(item .. '+', samba_options)
		end
	end

	for item in ipairs({ 'create_mask', 'dir_mask' }) do
		if V[item] then
			if string.len(V[item]) ~= 3 and string.len(V[item]) ~= 4 then
				return code.error(item .. ' Parameter must 3/4 word.', samba_options)
			end
			if V[item]:match('[89%D]') then
				return code.error(item .. '+', samba_options)
			end
		end
	end

	-- Check Wname
	if V.wname then
		if not uci:get('samba', wname) then
			return code.error('Wname+', samba_options)
		end
		-- TODO 判断类型
		-- TODO 判断重复
	end
	if not V.wname then
		if not V.name then
			return code.miss('Name+', samba_options)
		end
		if not V.path then
			return code.miss('Path+', samba_options)
		end

		wname = PBUCI.addUCISection('samba', 'sambashare', {
			name        = V.name,
			path        = V.path,
			users       = V.users,
			guest_ok    = V.guest_ok,
			create_mask = V.create_mask,
			dir_mask    = V.dir_mask,
			read_only   = V.read_only
		})
	end

	-- Setter
	local isSuc = PBUCI.setUCISection('samba', wname, {
		name        = V.name,
		path        = V.path,
		users       = V.users,
		guest_ok    = V.guest_ok,
		create_mask = V.create_mask,
		dir_mask    = V.dir_mask,
		read_only   = V.read_only
	})

	uci:commit('samba')

	if isSuc then PBCommand.run('/etc/init.d/samba restart') end

	return action_status()
end

--[[
	API: 设置Samba状态

	@param {String} stok     [必选]
	@param {String} sysauth  [必选]
	@param {String} type   	 [必选]
	@see setGlobal()
	@see setSub()
	@since 0.1.0
	@return @see action_status()
--]]
function setter ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local t = luci.http.formvalue('type') or nil

	if t == 'global' then
		return setGlobal()
	elseif t == 'sub' then
		return setSub()
	else
		return code.miss('Type+', samba_options)
	end

	return action_status()
end

--[[
	API: 删除Samba 目录

	@param {String} stok     [必选]
	@param {String} sysauth  [必选]
	@param {String} wname 	 [必选]
	@since 0.1.0
	@return @see action_status()
--]]
function delete ()
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local wname = luci.http.formvalue('wname') or nil
	if not wname then
		return code.miss('Wname+', samba_options)
	elseif not uci:get('samba', wname) then
		return code.error('Wname+', samba_options)
	end

	-- TODO 判断类型
	if not uci:get('samba', wname, 'name') or
		not uci:get('samba', wname, 'path') then
		return code.error('Wname+', samba_options)
	end

	uci:delete('samba', wname)

	uci:commit('samba')

	PBCommand.run('/etc/init.d/samba restart')

	return action_status()
end

function version ()
	return version, version_num
end
