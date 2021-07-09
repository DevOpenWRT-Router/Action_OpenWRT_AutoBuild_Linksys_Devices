local base      = require "luci.controller.api.index"
local PBCommand = require "luci.pb.PBCommand"
local PBUCI     = require "luci.pb.PBUCI"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()

local version     = '@@Version'
local version_num = '@@VersionNum'

local version_options = { version = version, version_num = version_num }

module("luci.controller.api.endpoint", package.seeall)

function index ()
	local page   = node("api", "endpoint")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 404
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "endpoint", "status"}, call("action_status"), nil, 0)
	entry({"api", "endpoint", "getter"}, call("action_status"), nil, 10)
	entry({"api", "endpoint", "setter"}, call("action_setter"), nil, 20)
end

function moduleStatus ()
	if not nixio.fs.access("/etc/config/endpoint") then
		return false
	end
	if not nixio.fs.access("/etc/init.d/endpoint") then
		return false
	end

	return true
end

function action_status ()
	if not moduleStatus() then
		return code.code40011(nil, version_options)
	end

	local content = {
		PBUCI.getUCISection('endpoint', 'endpoint')
	}

	return code.ok(content, version_options)
end

function action_setter ()
	if not moduleStatus() then
		return code.code40011(nil, version_options)
	end

	local _apiAuth = base.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		'enabled'
	})

	if not V.enabled then
		return code.miss('Enabled+', version_options)
	end
	local function testEnabled ()
		local testList = { '0', '1', 'on', 'off'}
		for _, item in ipairs(testList) do
			if item == V.enabled then
				return true
			end
		end
		return false
	end

	if 'string' ~= type(V.enabled) or string.len(V.enabled) == 0 or
		not testEnabled() then
		return code.error('Enabled+', version_options)
	end

	if V.enabled:match('^o') then
		if 'on' == V.enabled then V.enabled = '1' end
		if 'off' == V.enabled then V.enabled = '0' end
	end

	local isSuc = PBUCI.setUCISection('endpoint', 'endpoint', {
		enabled = V.enabled
	})

	if '1' == V.enabled then
		PBCommand.run('/etc/init.d/endpoint start')
	elseif '0' == V.enabled then
		PBCommand.run('/etc/init.d/endpoint stop')
	end

	action_status()
end
