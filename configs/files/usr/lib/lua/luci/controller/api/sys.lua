require "luci.version"

local sauth      = require "luci.controller.api.user"
local uci        = require("luci.model.uci").cursor()
local PBCommand  = require "luci.pb.PBCommand"
local PBDownload = require "luci.pb.PBDownload"
local PBUtil     = require "luci.pb.PBUtil"
local PBUCI      = require "luci.pb.PBUCI"
local code       = PBUtil.message()

module("luci.controller.api.sys", package.seeall)

function index ()
	entry({"api", "sys"}, nil, nil, 93).index = true
	-- user
	entry({"api", "sys", "password"}, alias("api", "user", "password"), nil, 20)
	entry({"api", "sys", "login"}, alias("api", "user", "login"), nil, 30)
	-- System Action
	entry({"api", "sys", "ntp"}, call("action_ntp"), nil, 40)
	entry({"api", "sys", "remote"}, call("action_remote"), nil, 42)
	entry({"api", "sys", "remote_firmware"}, call("action_remote_firmware"), nil, 43)
	entry({"api", "sys", "upload"}, call("action_upload"), nil, 48, false)
	entry({"api", "sys", "upload_progress"}, call("action_upload_progress"), nil, 49, false)
	entry({"api", "sys", "sysupdate"}, call("action_update"), nil, 50, false)
	entry({"api", "sys", "sysreset"}, call("action_reset"), nil, 51, false)
	entry({"api", "sys", "reboot"}, call("action_reboot"), nil, 52, false)
	entry({"api", "sys", "lang"}, call("action_lang"), nil, 60, false)
	entry({"api", "sys", "langlist"}, call("getLanglist"), nil, 61, false)
	entry({"api", "sys", "expert"}, call("action_expert_mode"), nil, 70, false)
	entry({"api", "sys", "hostname"}, call("action_hostname"), nil, 72, false)
	entry({"api", "sys", "backup"}, call("action_backup"), nil, 72, false)
	entry({"api", "sys", "restore"}, call("action_restore"), nil, 72, false)
	-- Log
	entry({"api", "sys", "syslog"}, call("action_syslog"), nil, 80)
	entry({"api", "sys", "dmesg"}, call("action_dmesg"), nil, 81)
	-- System Info
	entry({"api", "sys", "info"}, call("getInfo"), nil, 90)
	entry({"api", "sys", "machine"}, call("getMachine"), nil, 91)
	entry({"api", "sys", "time"}, call("getTime"), nil, 94)
	entry({"api", "sys", "date"}, call("getDate"), nil, 95)
	entry({"api", "sys", "version"}, call("getVersion"), nil, 98)
	-- Clients
	entry({"api", "sys", "clients"}, call("getClients"), nil, 100)
	entry({"api", "sys", "count"}, call("getClientCount"), nil, 101)
end

-- System Action

function _getNtp ()
	local rv = {{
		enabled = uci:get("system", "ntp", "enabled")
	}}
	return rv
end

function _setNtp ()
	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local enabled = luci.http.formvalue("enabled") or nil

	if not enabled then return code.code40001("Enabled+") end
	if enabled ~= "0" and enabled ~= "1" then
		return code.code40002("Enabled+")
	end

	if enabled == uci:get("system", "ntp", "enabled") then
		return code.code60001()
	end

	if enabled == "0" then
		luci.sys.call("env -i /etc/init.d/sysntpd stop >/dev/null")
		luci.sys.init.disable("sysntpd")
	else
		luci.sys.init.enable("sysntpd")
		luci.sys.call("env -i /etc/init.d/sysntpd start >/dev/null")
	end
	uci:set("system", "ntp", "enabled", enabled)

	uci:commit("system")

	return nil
end

function action_ntp ()
	local action = nil
	if luci.http.formvalue("enabled") or nil then
		action = _setNtp()
	end
	if action then return action end

	return code.code0(_getNtp())
end

function action_remote ()
	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		'type', 'log'
	})
	if not V.type or string.len(V.type) == 0 then
		V.type = 'stable'
	end
	if V.type ~= 'beta' and V.type ~= 'dev' then
		V.type = 'stable'
	end

	local _, model = luci.sys.sysinfo()
	local logPath  = '/tmp/' .. V.type
	local content  = nil

	local url = string.format('%s://%s.%s%s.%s/%s/%s/%s.json',
			'http', 'assets', 'pandor', 'abox', 'com.cn', 'ota',
			model:gsub(' ', '%%20'):lower(), V.type)

	if V.log and string.len(V.log) ~= 0 then
		if nixio.fs.access (logPath) then
			content = luci.sys.exec('cat /tmp/' .. V.type)
			if string.len(content) == 0 then
				content = PBDownload.getURLData(url:gsub('/ota/', '/changelog/'))
			end
		else
			content = PBDownload.getURLData(url:gsub('/ota/', '/changelog/'))
		end
		content = content:gsub('[\'\"]url[\'\"]:.-\.bin[\'\"],?', '')
	else
		content = PBDownload.getURLData(url)
	end

	if not content or string.len(content) == 0 then
		return code.empty()
	else
		code.ok({
			require('luci.json').decode(content)
		})
	end

	if not V.log then
		PBDownload.downloadFile(url:gsub('/ota/', '/changelog/'), logPath)
	end

	return
end

function action_remote_firmware ()
	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local V = PBUtil.getFormValue({
		'type', 'keep'
	})
	local logPath   = '/tmp/' .. V.type
	local image_tmp = "/tmp/firmware.img"

	if not V.keep then
		nixio.fs.unlink(image_tmp)
		if not V.type or string.len(V.type) == 0 then
			V.type = 'stable'
		end
		if V.type ~= 'beta' and V.type ~= 'dev' then
			V.type = 'stable'
		end

		local _, model = luci.sys.sysinfo()

		local content = nil

		if nixio.fs.access (logPath) then
			content = luci.sys.exec('cat /tmp/' .. V.type)
			if not content or string.len(content) == 0 then
				return code.code40009('Log File Miss')
			end
		else
			return code.code40009('Log File Miss')
		end

		local url = ''

		url = content:match('[\'\"]url[\'\"]:.-(http:.-\.bin)[\'\"]')
		if not url or string.len(url) == 0 then
			return code.code40009('Log File Miss')
		end

		PBDownload.downloadFile(url, image_tmp)

		return code.ok()
	else
		return action_update()
	end

end

function action_upload ()
	local image_tmp = "/tmp/firmware.img"

	local function image_supported ()
		-- XXX: yay...
		return ( 0 == os.execute(
			". /lib/functions.sh; " ..
			"include /lib/upgrade; " ..
			"platform_check_image %q >/dev/null"
				% image_tmp
		) )
	end

	local fd   = nil
	luci.http.setfilehandler(function(field, chunk, eof)
		if not field then return end
		if not fd then
			fd = io.open(image_tmp, "w")
		end
		if fd then
			fd:write(chunk)
		end
		if eof and fd then
			fd:close()
			fd = nil
		end
	end)

	if luci.http.formvalue("image") then
		if image_supported() then
			-- 有效文件
			return code.code0()
		else
			-- 无效文件
			nixio.fs.unlink(image_tmp)
			code.code40008()
		end
	else
		return code.code40009()
	end
end

function action_upload_progress ()
	local image_tmp = "/tmp/firmware.img"
	local rv = {}

	if nixio.fs.access(image_tmp) then
		rv[#rv+1] = { size = nixio.fs.stat(image_tmp).size }
	else
		rv[#rv+1] = { size = -1 }
	end

	return code.code0(rv)
end

function action_update ()
	local image_tmp = "/tmp/firmware.img"

	local function image_supported ()
		-- XXX: yay...
		return ( 0 == os.execute(
			". /lib/functions.sh; " ..
			"include /lib/upgrade; " ..
			"platform_check_image %q >/dev/null"
				% image_tmp
		) )
	end

	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	if not nixio.fs.access(image_tmp) then
		return code.code40008()
	end

	if not image_supported() then
		code.code40008()
	end

	local V = PBUtil.getFormValue({ 'keep' })
	if not V.keep or (V.keep ~= '0' and V.keep ~= '1') then
		V.keep = '1'
	end
	local keepFlag = ' '
	if V.keep == '0' then
		keepFlag = ' -n '
	end

	code.code60004()

	PBCommand.run({
		[[grep '"rootfs_data"' /proc/mtd >/dev/null 2>&1]],
		"sleep 1; killall dropbear uhttpd; sleep 1; /sbin/sysupgrade " .. keepFlag .. " %q; reboot" % image_tmp
	})
end

function action_reset ()
	local reset_avail = os.execute([[grep '"rootfs_data"' /proc/mtd >/dev/null 2>&1]]) == 0

	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	if reset_avail and luci.http.formvalue("reset") then
		-- luci.template.render("reboot")
		code.code60005()

		uci:set("user", "sys", "guide", 0)

		uci:commit("user")
		luci.sys.exec("sleep 1; killall dropbear; sleep 1; firstboot -y; reboot")
		return
	else
		return code.code40002("Reset+")
	end
	return code.code40010("sys.lua->action_reset+")
end

function action_reboot ()
	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	code.code60006()

	luci.sys.exec("sleep 1;reboot")
	return
end

function _getLanglist ()
	local rv = {}
	local i18ndir = luci.i18n.i18ndir .. "base."
	for k, v in luci.util.kspairs(luci.config.languages) do
		local file = i18ndir .. k:gsub("_", "-")
		if k:sub(1, 1) ~= "." and nixio.fs.access(file .. ".lmo") then
			rv[#rv+1] = {
				key = k,
				value = v
			}
		end
	end
	rv[#rv+1] = {key = "auto", value = "auto"}
	return rv
end

function getLanglist()
	local action = _getLanglist()
	if action then
		return code.code0(action)
	else
		return code.code40003(action)
	end
	return code.code40010("sys.lua->getLanglist")
end

function action_lang ()
	local _lang  = uci:get("user", "sys", "lang")
	local lang   = luci.http.formvalue("lang") or nil
	local custom = luci.http.formvalue('custom') or nil
	if lang then
		local _apiAuth = sauth.checkApiAuth()
		if _apiAuth then return _apiAuth end

		if uci:get("user", "sys", "lang") == lang then
			return code.code60001()
		end

		-- Lang Checker
		local isExist = false
		local i18ndir = luci.i18n.i18ndir .. "base."
		for k, v in luci.util.kspairs(luci.config.languages) do
			local file = i18ndir .. k:gsub("_", "-")
			if k:sub(1, 1) ~= "." and nixio.fs.access(file .. ".lmo") and
				k == lang then
				isExist = true
			end
		end

		if custom then
			isExist = true
		end

		if lang == "auto" then
			isExist = true
		end

		if not isExist then
			return code.code40002("Lang+")
		end

		_lang = lang

		uci:set('luci', 'main', 'lang', lang)
		uci:set("user", "sys", "lang", lang)

		uci:commit('luci')
		uci:commit("user")
	end

	if not _lang then
		_lang = uci:get('user', 'sys', 'lang')
	end

	local rv = {{
		lang = _lang
	}}

	return code.code0(rv)
end

function action_expert_mode ()
	local mode = luci.http.formvalue("expert") or nil
	if mode then
		if mode ~= "0" and mode ~= "1" then
			return code.code40002("Expert Mode+")
		end
		local _apiAuth = sauth.checkApiAuth()
		if _apiAuth then return _apiAuth end

		if uci:get("user", "sys", "expert") == mode then
			return code.code60001()
		end

		uci:set("user", "sys", "expert", mode)

		uci:commit("user")
	end

	local _flag = uci:get("user", "sys", "expert")

	if not _flag then
		return code.code40003("Expert+")
	end

	local rv = {{
		expert_mode = _flag
	}}

	return code.code0(rv)
end

function action_hostname ()
	local V = PBUtil.getFormValue({
		"hostname", "_method"
	})

	if not V['_method'] then
		return code.miss('Method+')
	elseif 'string' ~= type(V['_method']) then
		return code.error('Method+')
	else
		V['_method'] = V['_method']:upper()
	end

	local item = PBUCI.getUCIList('system', 'system')[1]

	if 'GET' == V['_method'] then
		return code.ok({{
			hostname = item.hostname
		}})
	end
	if 'PUT' == V['_method'] then
		local _apiAuth = sauth.checkApiAuth()
		if _apiAuth then return _apiAuth end

		if not V.hostname then
			return code.miss('hostname+')
		end
		if 'string' ~= type(V.hostname) then
			return code.error('hostname+')
		end

		PBUCI.setSection('system', item.wname, {
			hostname = V.hostname
		}):commit(function ()
			item.hostname = V.hostname
		end)

		PBCommand.run('/etc/init.d/system restart')
	end

	return code.ok({{
		hostname = item.hostname
	}})
end

-- Log

function action_syslog ()
	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local log = luci.sys.syslog()
	if log then
		luci.http.prepare_content("text/plain")
		luci.http.write(log:pcdata())
		return
	end
	return code.code40010("sys.lua->action_syslog+")
end

function action_dmesg ()
	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	local dmesg = luci.sys.dmesg()
	if dmesg then
		luci.http.prepare_content("text/plain")
		luci.http.write(dmesg:pcdata())
		return
	end
	return code.code40010("sys.lua->action_dmesg+")
end

-- System Info
function getInfo ()
	local versions = luci.version or { }
	local rv = {}
	-- Version
	local versions = {
		distName    = versions.distname or '',
		distVersion = versions.distversion or '',
		luciName    = versions.luciname or '',
		luciVersion = versions.luciversion or ''
	}
	versions.apiVersion, versions.apiVersionNum = require("luci.pb.index").getVersion()
	rv.versions = versions

	-- Date
	rv.date = os.time()

	-- Guide
	rv.hasGuide = nixio.fs.access('/usr/lib/lua/luci/controller/api/guide.lua') or false
	if rv.hasGuide then
		rv.isGuide = uci:get('user', 'sys', 'guide') or '0'
	else
		rv.isGuide = '0'
	end

	-- Expert
	rv.isExpert = uci:get("user", "sys", "expert") or nil

	-- Module Status
	local modules = {
		hasWireless  = '/usr/lib/lua/luci/controller/api/wifi.lua',
		hasHwacc     = '/usr/lib/lua/luci/controller/api/hwacc.lua',
		hasQos       = '/usr/lib/lua/luci/controller/api/qos.lua',
		hasBandwidth = '/usr/lib/lua/luci/controller/api/bandwidth.lua',
		hasStatic    = '/usr/lib/lua/luci/controller/api/dhcp.lua',
		hasUpnp      = '/usr/lib/lua/luci/controller/api/upnp.lua',
		hasDDNS      = '/usr/lib/lua/luci/controller/api/ddns.lua',
		hasDMZ       = '/usr/lib/lua/luci/controller/api/dmz.lua',
		hasSamba     = '/usr/lib/lua/luci/controller/api/samba.lua',
		hasFtpd      = '/usr/lib/lua/luci/controller/api/ftpd.lua'
	}

	for key, path in pairs(modules) do
		local function getModuleStatus ()
			if not nixio.fs.access(path) then return false end

			local moduleName = path:gsub('/usr/lib/lua/', ''):gsub('%.lua$', ''):gsub('/', '.')

			if not require(moduleName).moduleStatus then return false end

			return require(moduleName).moduleStatus()
		end
		rv[key] = getModuleStatus()
	end

	-- Language
	rv.lang = uci:get("luci", "main", "lang")

	-- Themes
	local function isMultiThemes ()
		local list = {}
		for _, v in ipairs(require('luci.fs').dir('/www/luci-static')) do
			if v ~= '.' and v ~= '..' then
				list[#list+1] = v
			end
		end
		if #list > 2 then
			return true
		end
		return false
	end
	rv.isMultiThemes = isMultiThemes()

	-- 当前访问IP地址
	rv.curip = luci.http.getenv("REMOTE_ADDR")

	-- @TODO 插件列表

	if rv then
		return code.code0({rv})
	else
		return code.code40003("System Info+")
	end
	return code.code40010("sys.lua->getInfo+")
end


--[[
	获取机器信息

	@since 0.3.0

	@return {Array}
--]]
function getMachine ()
	local rv = {
		time     = luci.sys.uptime(),
		date     = os.time(),
		hostname = luci.sys.hostname() or '?',
		versions = {
			distname    = luci.version.distname,
			distversion = luci.version.distversion,
			luciname    = luci.version.luciname,
			luciversion = luci.version.luciversion
		},
		kernelVersion = luci.sys.exec('uname -r')
	}
	local sysinfo = luci.util.ubus("system", "board") or { }
        rv.system, rv.model = sysinfo.system, sysinfo.model
	-- rv.system, rv.model = luci.sys.sysinfo()
	rv.cpuinfo = {
		num     = luci.sys.exec('cat /proc/cpuinfo | grep processor | wc -l'):match('%d+'),
		-- loadavg = { luci.sys.loadavg() }
		loadavg = luci.util.ubus("system", "info").load
	}
	rv.versions.apiVersion, rv.versions.apiVersionNum = require("luci.pb.index").getVersion()
	-- Mem and Swap

	if sauth.checkAuth() then
		-- local _, _, memtotal, memcached, membuffers, memfree, _, swaptotal, swapcached, swapfree = luci.sys.sysinfo()
		local info = luci.util.ubus("system", "info") or { }
                local memtotal, memfree, memcached, membuffers = info.memory.total, info.memory.free, info.memory.shared, info.memory.buffered
                local swaptotal, swapfree = info.swap.total, info.swap.free
		rv.mem = {
			memtotal   = memtotal,
			memcached  = memcached,
			membuffers = membuffers,
			memfree    = memfree
		}

		if (swaptotal or 0) > 0 then
			rv.swap = {
				swaptotal  = swaptotal,
				swapcached = swaptotal - swapfree,
				swapfree   = swapfree
			}
		end
	end

	rv = { rv }
	if #rv > 0 then
		return code.ok(rv)
	else
		return code.empty("Machine Info+")
	end
	code.unknown("sys.lua->getMachine+");
end

function getTime ()
	local rv = {{
		time = luci.sys.uptime()
	}}
	if #rv > 0 then
		return code.code0(rv)
	else
		return code.code40003("System Time+")
	end
	code.code40010("sys.lua->getTime+");
end

function getDate ()
	local rv = {{
		time = os.time()
	}}
	if #rv > 0 then
		return code.code0(rv)
	else
		return code.code40003("System Date+")
	end
	return code.code40010("sys.lua->getDate+");
end

function getVersion ()
	local versions = {
		distname    = luci.version.distname,
		distversion = luci.version.distversion,
		luciname    = luci.version.luciname,
		luciversion = luci.version.luciversion
	}
	versions.apiVersion, versions.apiVersionNum = require("luci.pb.index").getVersion()
	local rv = {}
	-- Import
	rv[#rv+1] = versions
	if #rv > 0 then
		return code.code0(rv)
	else
		return code.code40003("System Version+")
	end
	return code.code40010("sys.lua->getVersion+");
end

function _getClients ()
	local rv = luci.sys.net.arptable() or {}
	return rv
end

function getClients ()
	local action = _getClients()

	if #action == 0 then
		return code.code40003("Client+")
	else
		return code.code0(action)
	end
	return code.code40010("lan.lua->getClients+")
end

function getClientCount ()
	local rv = {{
		count = #_getClients()
	}}

	return code.code0(rv)
end

function action_backup ()
	local reader = ltn12_popen("sysupgrade --create-backup - 2>/dev/null")

	luci.http.header(
		'Content-Disposition', 'attachment; filename="backup-%s-%s.tar.gz"' %{
			luci.sys.hostname(),
			os.date("%Y-%m-%d")
		})

	luci.http.prepare_content("application/x-targz")
	luci.ltn12.pump.all(reader, luci.http.write)
end

-- backup 用
function ltn12_popen(command)

	local fdi, fdo = nixio.pipe()
	local pid = nixio.fork()

	if pid > 0 then
		fdo:close()
		local close
		return function()
			local buffer = fdi:read(2048)
			local wpid, stat = nixio.waitpid(pid, "nohang")
			if not close and wpid and stat == "exited" then
				close = true
			end

			if buffer and #buffer > 0 then
				return buffer
			elseif close then
				fdi:close()
				return nil
			end
		end
	elseif pid == 0 then
		nixio.dup(fdo, nixio.stdout)
		fdi:close()
		fdo:close()
		nixio.exec("/bin/sh", "-c", command)
	end
end

function action_restore ()
	local fs = require "nixio.fs"
	local http = require "luci.http"
	local archive_tmp = "/tmp/restore.tar.gz"

	local fp
	http.setfilehandler(
		function(meta, chunk, eof)
			if not fp then
				fp = io.open(archive_tmp, "w")
			end
			if fp and chunk then
				fp:write(chunk)
			end
			if fp and eof then
				fp:close()
			end
		end
	)

	local _apiAuth = sauth.checkApiAuth()
	if _apiAuth then return _apiAuth end

	if not luci.dispatcher.test_post_security() then
		fs.unlink(archive_tmp)
		return
	end

	os.execute("tar -C / -xzf %q >/dev/null 2>&1" % archive_tmp)
	code.code60006()
	luci.sys.reboot()
end