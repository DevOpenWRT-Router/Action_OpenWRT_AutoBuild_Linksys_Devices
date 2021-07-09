local logger = require "luci.pb.PBLog"

module('luci.pb.PBDownload', package.seeall)

function getURLData (url)
	logger.info('[PBDownload]Downloading from ' .. url)
	local content = luci.sys.exec("wget " .. url .. " -qO- 2>/dev/null")
	logger.info('[PBDownload]Downloaded form ' .. url)
	return content
end

function downloadFile (url, path)
	if not path or type(path) ~= 'string' then
		path = '/tmp/unknownFile'
	end

	logger.info(string.format('[PBDownload]Downloading from %s to %s',url,path))
	local content = luci.sys.exec("wget " .. url .. " -O  " .. path .. " 2>/dev/null")
	logger.info(string.format('[PBDownload]Downloaded form %s to %s',url,path))

	return content
end
