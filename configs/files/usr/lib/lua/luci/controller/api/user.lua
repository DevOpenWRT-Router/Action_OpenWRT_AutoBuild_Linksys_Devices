local fs        = require "nixio.fs"
local sys       = require "luci.sys"
local util      = require "luci.util"
local http      = require "luci.http"
local nixio     = require "nixio", require "nixio.util"
local PBUCI     = require "luci.pb.PBUCI"
local PBCommand = require "luci.pb.PBCommand"
local PBUtil    = require "luci.pb.PBUtil"
local code      = PBUtil.message()

module("luci.controller.api.user", package.seeall)

function index ()
	local page   = node("api", "user")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 101
	page.sysauth = false
	page.ucidata = true
	page.index = true

	entry({'api', 'user', 'status'}, call('action_status'), nil, 0)
	entry({"api", "user", "login"}, call("login"), nil, 10)
	entry({"api", "user", "password"}, call("changePassword"), nil, 20)
end

function action_status ( )
	local sysauth = http.getcookie("sysauth")
	sysauth = sysauth and sysauth:match("^[a-f0-9]*$")

	if not sysauth then
		return code.miss()
	end

	local isAuth = (util.ubus("session", "get", { ubus_rpc_session = sysauth }) or { }).values
	if not isAuth then
		return code.error()
	end

	return code.ok()
end

--[[
	检查用户信息(函数用)

	@since 0.3.0
	@param {String} stok
	@param {String} sysauth

	@return {Boolean}
--]]
function checkAuth()
	-- 密码途径
	local V = PBUtil.getFormValue({
		"username", "user", "password", "pwd"
	})
	V.username = V.username or V.user or nil
	V.password = V.password or V.pwd or nil

	if V.username and V.password and luci.sys.user.checkpasswd(V.username, V.password) then
		return true
	end

	-- 正规途径
	local sysauth = http.getcookie("sysauth")
	sysauth = sysauth and sysauth:match("^[a-f0-9]*$")

	if not sysauth then
		return false
	end

	local isAuth = (util.ubus("session", "get", { ubus_rpc_session = sysauth }) or { }).values
	if not isAuth then
		return false
	end

	return true
end

--[[
	检查用户信息(接口用)

	@since 0.1.0
	@param {String} stok
	@param {String} sysauth

	@return {String} ErrorInfo
--]]
function checkApiAuth ()
	if checkAuth() then
		return nil
	end

	local sysauth = http.getcookie("sysauth")
	sysauth = sysauth and sysauth:match("^[a-f0-9]*$")

	if not sysauth then
		return code.code40001("Sysauth+")
	end

	return nil
end

function login ()
	local V = PBUtil.getFormValue({
		"username", "user", "password", "pwd"
	})
	V.username = V.username or V.user or nil
	V.password = V.password or V.pwd or nil

	-- Empty Value return 404
	if not V.username then
		return code.code40001("Username+")
	end
	if not V.password then
		return code.code40001("Password+")
	end
	if V.username and not luci.sys.user.checkpasswd(V.username, V.password) then
		return code.code40002("Username or Password+")
	end
	local rv = {}
	rv.user = V.username

	local sdat = util.ubus("session", "create", { timeout = tonumber(luci.config.sauth.sessiontime) })
	if sdat then
		token = sys.uniqueid(16)
		util.ubus("session", "set", {
			ubus_rpc_session = sdat.ubus_rpc_session,
			values = {
				user = user,
				token = token,
				section = sys.uniqueid(16)
			}
		})
		sess = sdat.ubus_rpc_session
	end
	if sess and token then
		rv.date = os.time()
		rv.limit = luci.config.sauth.sessiontime
		rv.sysauth = sess
		http.header("Set-Cookie", 'sysauth=%s; path=%s' %{ sess, luci.dispatcher.build_url() })
		return code.code0({ rv })
	else
		return code.code40003()
	end
	return code.code40010("sys.lua->action_login+")
end

function changePassword ()
	local _apiAuth = checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		'username', 'old_passwd', 'new_passwd'
	})

	for _, item in ipairs({ 'old_passwd', 'new_passwd' }) do
		local function getErrorTextHead (text)
			return text:gsub('^.', text:match('^.'):upper())
		end
		if not V[item] then
			return code.miss(getErrorTextHead(item) .. '+')
		end
		if 'string' ~= type(V[item]) or string.len(V[item]) == 0 then
			return code.error(getErrorTextHead(item) .. '+')
		end
	end

	if not V.username then
		V.username = "root"
	end
	if V.old_passwd == V.new_passwd then
		return code.same()
	end
	if luci.sys.user.checkpasswd(V.username, V.new_passwd) then
		return code.error("New_Passwd+")
	end
	if not luci.sys.user.checkpasswd(V.username, V.old_passwd) then
		return code.error("Old_Passwd+")
	end
	-- Setter
	luci.sys.user.setpasswd(V.username, V.new_passwd)

	return code.ok()

	-- code.code40010("user.lua->changePassword+")
end
