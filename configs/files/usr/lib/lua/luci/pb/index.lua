module("luci.pb.index", package.seeall)

local version     = "0.2.6"
local version_num = 13

function index ()
end

function returnJson (content, options)
	local rv       = {}
	rv.version     = version
	rv.version_num = version_num
	if options.version then
		rv.module_version = options.version
	end
	if options.version_num then
		rv.module_version_num = options.version_num
	end

	rv.code      = options.code
	rv.code_info = options.text

	if not content then
		rv.content = nil
	else
		rv.content = content
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
	return
end

function getVersion ()
	return version, version_num
end
