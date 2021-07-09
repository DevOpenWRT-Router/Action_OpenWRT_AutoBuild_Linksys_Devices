local fs     = require 'luci.fs'
local base   = require "luci.controller.api.index"
local PBUtil = require "luci.pb.PBUtil"
local PBLog  = require "luci.pb.PBLog"
local code   = require "luci.pb.code"

module("luci.controller.api.plugin", package.seeall)

function index ()
	local page   = node("api", "plugin")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 800
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "plugin", "list"}, call("getList"), nil, 10)
	entry({"api", "plugin", "remote"}, call("action_remote"), nil, 10)
end

local plugin_prefix = "plugin_"

function getList ( )
	local rv = {}

	local path = '/usr/lib/lua/luci/controller/api/'
	for _, item in ipairs(fs.dir(path)) do
		local name = item:match('^' .. plugin_prefix .. '(.*)\.lua$')
		if name then
			local module = require('luci.controller.api.' .. plugin_prefix .. name)
			local tmp    = {
				name = name
			}
			if module.moduleStatus then
				tmp.status = module.moduleStatus()
			else
				tmp.status = false
			end
			if module.version then
				tmp.version, tmp.version_num = module.version()
			end
			rv[#rv+1] = tmp
		end
	end

	if #rv == 0 then
		return code.code40003()
	end
	return code.code0(rv)
end

function getStatus ( )
	local rv = {}

	local path = '/usr/lib/lua/luci/controller/api/'
	for _, item in ipairs(fs.dir(path)) do
		local name = item:match('^' .. plugin_prefix .. '(.*)\.lua$')
		if name then
			local module = require('luci.controller.api.' .. plugin_prefix .. name)
			local status = false
			if module.moduleStatus then
				status = module.moduleStatus()
			end
			rv['has' .. name:gsub('^%l', name:match('^.'):upper())] = status
		end
	end

	if #rv == 0 then
		rv = nil
	end
	return rv
end

function action_remote ( )
	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue("_method")

	if not V['_method'] then
		return code.miss('Method+')
	elseif 'string' ~= type(V['_method']) then
		return code.error('Method+')
	else
		V['_method'] = V['_method']:upper()
	end

	if 'GET' == V['_method'] then
		return getRemoteList()
	elseif 'PUT' == V['_method'] then
		return updatePlugin()
	elseif 'POST' == V['_method'] then
		return addPlugin()
	elseif 'DELETE' == V['_method'] then
		return delPlugin()
	else
		return code.error('Method+')
	end
end

local opkg = require 'luci.model.ipkg'
function getRemoteList ( )
	local V = PBUtil.getFormValue("query")
	V.query = V.query or ''

	local update, out, err = opkg.update()

	if update == 0 then
		local flag = { }
		opkg.list_all('%s*' % V.query, function (n, v, d)
			--[[
				n: Package Name
				v: Version
				d: Description
			--]]
			flag[n] = {
				name        = luci.util.pcdata(n),
				version     = luci.util.pcdata(v),
				description = luci.util.pcdata(d)
			}
		end)
		opkg.list_installed('%s*' % V.query, function (n)
			flag[n].installed = true
		end)
		local list = { }
		for _, item in pairs(flag) do
			list[#list+1] = item
		end

		if #list ~= 0 then
			return code.ok(list)
		else
			return code.empty()
		end
	else
		return code.code50001()
	end
end

function updatePlugin ( )
	local V = PBUtil.getFormValue("pkg")

	if not V.pkg then
		return code.miss('Package Name+')
	end

	if opkg.installed(V.pkg) then
		if opkg.install(V.pkg) then
			return code.ok()
		else
			return code.code50001()
		end
	else
		return code.error(V.pkg .. ' isnt Existed')
	end
end

function addPlugin ( )
	local V = PBUtil.getFormValue("pkg")

	if not V.pkg then
		return code.miss('Package Name+')
	end

	if not opkg.installed(V.pkg) then
		if opkg.install(V.pkg) then
			return code.ok()
		else
			return code.code50001()
		end
	else
		return code.error(V.pkg .. ' Installed')
	end
end

function delPlugin ( )
	local V = PBUtil.getFormValue("pkg")

	if not V.pkg then
		return code.miss('Package Name+')
	end

	if opkg.installed(V.pkg) then
		if opkg.remove(V.pkg) then
			return code.ok()
		else
			return code.unknown()
		end
	else
		return code.error(V.pkg .. ' isnt Existed')
	end
end
