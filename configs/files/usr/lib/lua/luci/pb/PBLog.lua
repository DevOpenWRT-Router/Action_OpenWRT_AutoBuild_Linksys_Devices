module('luci.pb.PBLog', package.seeall)

local Log_Enabled = true
local Log_DEBUG = false


function print (text, type)
	if not Log_Enabled then return end
	local Log_Dir = '/tmp/log/pb/'
	if not nixio.fs.access(Log_Dir) then
		nixio.fs.mkdirr(Log_Dir)
	end

	local date = os.date('%Y-%m-%d', os.time())
	local time = os.date('%X', os.time())
	local logPath = Log_Dir .. date .. '.log'

	-- Echo 'HH:mm:ss [Test]'
	return os.execute(string.format("echo '[%s][%s]%s' >> %s",type:upper(),time,text,logPath))
end

function debug (text)
	if not Log_Enabled then return end
	if not Log_DEBUG then return end

	return print(text, 'debug')
end

function info (text)
	if not Log_Enabled then return end

	return print(text, 'info')
end

function warn (text)
	if not Log_Enabled then return end

	return print(text, 'warn')
end

function error (text)
	if not Log_Enabled then return end

	return print(text, 'error')
end

function log (text)
	return debug(text)
end

function warning (text)
	return warn(text)
end

function err (text)
	return error(text)
end
