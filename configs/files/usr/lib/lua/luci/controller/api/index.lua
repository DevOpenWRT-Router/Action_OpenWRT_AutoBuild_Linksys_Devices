module("luci.controller.api.index", package.seeall)

function index ()
	local page   = node("api")
	page.target  = firstchild()
	page.title   = nil
	page.order   = 97
	page.sysauth = false
	page.ucidata = true
	page.index   = true

	entry({"api", "sysauth"}, alias("api", "user", "login"), nil, 100)
end

function checkAuth ()
	return require("luci.controller.api.user").checkAuth()
end

function checkApiAuth ()
	return require("luci.controller.api.user").checkApiAuth()
end

