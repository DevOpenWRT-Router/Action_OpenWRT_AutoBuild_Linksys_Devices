local uci = require("luci.model.uci").cursor()
local code = require("luci.pb.code")

module("luci.controller.api.status", package.seeall)

function index ()
	entry({"api", "status"}, call("error"), nil, 20).index = true
	entry({"api", "status", "wan"}, alias("api", "wan", "status"), nil, 10)
	entry({"api", "status", "lan"}, alias("api", "lan", "status"), nil, 12)
	entry({"api", "status", "wifi"}, alias("api", "wifi", "status"), nil, 14)
	entry({"api", "status", "sys"}, alias("api", "sys", "info"), nil, 16)
end

function error ()
	code.code40003()
end
