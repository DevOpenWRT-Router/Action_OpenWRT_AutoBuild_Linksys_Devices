module("luci.controller.admin.lafite", package.seeall)

function index()
	local root = node()
	if not root.target then
		root.target = alias("lafite")
		root.index = true
	end

	function jump ()
		local uci = require("luci.model.uci").cursor()

		local themename = uci:get('luci', 'main', 'mediaurlbase') or nil

		if not themename then
			return template("jump")
		end

		themename = themename:match('([%da-zA-Z]*)$')
		if themename == 'lafite' then
			return template("jump")
		else
			local list = {}
			for _, v in ipairs(require('luci.fs').dir('/www/luci-static')) do
				if v ~= '.' and v ~= '..' then
					list[#list+1] = v
				end
			end
			if #list > 2 then
				return alias("admin")
			end
		end
		return template("jump")
	end

	local page = entry({"lafite"}, jump(), nil, 0)
	page.sysauth = false
	page.ucidata = true
	page.index = true

	entry({"lafite", "change"}, call("action_change"), _("index"), 0)
end

function action_change()
	local sauth = require "luci.controller.api.user"
	local PBUtil = require "luci.pb.PBUtil"
	local code = PBUtil.message()

	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({ 'change' })

	if not V.change then
		return code.miss('Change+')
	end
	if V.change ~= '0' and V.change ~= '1' then
		return code.error('Change+')
	end

	local themename = 'lafite'
	if V.change == '1' then
		local list = {}
		for _, v in ipairs(require('luci.fs').dir('/www/luci-static')) do
			if v ~= '.' and v ~= '..' then
				list[#list+1] = v
			end
		end
		if #list > 2 then
			for _, v in ipairs(list) do
				if v ~= 'lafite' and v ~= 'resources' then
					themename = v
				end
			end
		end
	end

	PBUtil.setUCISection('luci', 'main', {
		mediaurlbase = '/luci-static/' .. themename
	})

	uci:commit('luci')

	return code.ok()
end
