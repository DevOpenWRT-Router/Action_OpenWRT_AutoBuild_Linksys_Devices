local base = require "luci.pb.index"

module("luci.pb.code", package.seeall)

function index ()
end

local function codeCommon (content, code, text, options)
	if not options then
		options = {}
	end
	if type(content) == "string" then
		if not options.text then
			options.text = content
		end
		content = nil
	end
	options.code = code
	if options.text then
		local prefix, info, suffix = options.text:match("^(%+?)(%w.*%w)(%+?)$")
		if prefix ~= "" and info then
			options.text = text .. " " .. info
		elseif suffix ~= "" and info then
			options.text = info .. " " .. text
		end
	else
		options.text = text
	end

	options.text = options.text:gsub('^%l', options.text:match('^.'):upper())

	base.returnJson(content, options)
	return options.text
end

-- Success
function code0 (content, options)
	local text = "Okay."
	return codeCommon(content, 0, text, options)
end

-- Error
function code40001 (content, options)
	local text = "Parameter Miss."
	return codeCommon(content, 40001, text, options)
end

function code40002 (content, options)
	local text = "Parameter Error."
	return codeCommon(content, 40002, text, options)
end

function code40003 (content, options)
	local text = "List is Empty."
	return codeCommon(content, 40003, text, options)
end

function code40004 (content, options)
	local text = "The Wname is not Exist."
	return codeCommon(content, 40004, text, options)
end

function code40005 (content, options)
	local text = "The Device is not Exist."
	return codeCommon(content, 40005, text, options)
end

function code40006 (content, options)
	local text = "IP Error."
	return codeCommon(content, 40006, text, options)
end

function code40007 (content, options)
	local text = "MAC Error."
	return codeCommon(content, 40007, text, options)
end

function code40008 (content, options)
	local text = "Image File is Invalid."
	return codeCommon(content, 40008, text, options)
end

function code40009 (content, options)
	local text = "The Image File Miss."
	return codeCommon(content, 40009, text, options)
end

function code40010 (content, options)
	local text = "Unknown Error."
	return codeCommon(content, 40010, text, options)
end

function code40011 (content, options)
	local text = "Module Not Found."
	return codeCommon(content, 40011, text, options)
end

-- Network
function code50001 (content, options)
	local text = "Check Your Network."
	return codeCommon(content, 50001, text, options)
end

-- Info
function code60001 (content, options)
	local text = "Everything is Same."
	return codeCommon(content, 60001, text, options)
end

function code60002 (content, options)
	local text = "Image File is uploading."
	return codeCommon(content, 60002, text, options)
end

function code60003 (content, options)
	local text = "Image File is uploaded."
	return codeCommon(content, 60003, text, options)
end

function code60004 (content, options)
	local text = "System will Update."
	return codeCommon(content, 60004, text, options)
end

function code60005 (content, options)
	local text = "System will Reset."
	return codeCommon(content, 60005, text, options)
end

function code60006 (content, options)
	local text = "System will reboot."
	return codeCommon(content, 60006, text, options)
end

function code60007 (content, options)
	local text = "New Password will Begin to Use."
	return codeCommon(content, 60007, text, options)
end

-- Alias
function ok (content, options)
	return code0(content, options)
end

function miss (content, options)
	return code40001(content, options)
end

function error (content, options)
	return code40002(content, options)
end

function empty (content, options)
	return code40003(content, options)
end

function nowname (content, options)
	return code40004(content, options)
end

function unknown (content, options)
	return code40010(content, options)
end

function same (content, options)
	return code60001(content, options)
end
