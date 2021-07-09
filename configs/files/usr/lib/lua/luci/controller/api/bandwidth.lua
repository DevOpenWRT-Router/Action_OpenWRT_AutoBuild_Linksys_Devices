local PBUtil = require "luci.pb.PBUtil"
local code   = PBUtil.message()

local version     = '0.1.1'
local version_num = 5

local bandwidth_options = {version = version, version_num = version_num}

module("luci.controller.api.bandwidth", package.seeall)

function index()
	local page   = node("bandwidth")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 97
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "bandwidth"}, alias("api", "bandwidth", "ipbandwidth"), nil, 93).index = true
	entry({"api", "bandwidth", "ipbandwidth"}, call("getIpbandwidth"), nil, 100)
	entry({"api", "bandwidth", "devicebandwidth"}, call("getDeviceBandwidth"), nil, 102)
end

function moduleStatus ()
	return true
end

function _getIpbandwidth ()
	local bwc = io.popen("cat /proc/bandwidth 2>/dev/null")
	local data = {}

	if bwc then
		local ln
		repeat
			ln = bwc:read("*l")
			if not ln then break end
			local obj = {}
			obj.ip, obj.mac, obj.download, obj.upload =
				ln:match("(%d*\.%d*\.%d*\.%d*) (%w+:%w+:%w+:%w+:%w+:%w+) (%d+) (%d+),")
			data[#data+1] = obj
		until not ln
	end

	return data
end

function getIpbandwidth ()
	local rv = {}

	rv.date = os.time()
	rv.data = _getIpbandwidth()

	code.code0(rv, bandwidth_options)
	return
end

function getDeviceBandwidth ()
	local V = PBUtil.getFormValue({ 'device' })

	if not V.device then
		return code.miss('Device+', bandwidth_options)
	end

	local rv = {}

	local bwc = io.popen("luci-bwc -i %q 2>/dev/null" % V.device)
	if bwc then
		local obj = nil
		while true do
			local ln = bwc:read("*l")
			if not ln then break end

			obj = {}
			for value in ln:gmatch('(%d+)') do
				obj[#obj+1] = tonumber(value)
			end

			if #obj > 0 then
				rv[#rv+1] = obj
			end
		end

		bwc:close()
	end

	if #rv > 0 then
		return code.ok(rv, bandwidth_options)
	else
		return code.empty(nil, bandwidth_options)
	end

end
