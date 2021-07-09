local uci    = require("luci.model.uci").cursor()
local logger = require "luci.pb.PBLog"

module('luci.pb.PBUCI', package.seeall)

PBUCI = { }
PBUCI.__index = PBUCI

function PBUCI.new ()
	local uci = {
		content = {}
	}
	setmetatable(uci, PBUCI)
	return uci
end

function PBUCI.get (self)
	return self.content
end

--[[
	获取UCI Section 数据

	@since 0.3.0
	@param {String} config	[UCI config]
	@param {String} section	[UCI section]
	@param {String} option	[UCI option]

	@return {Array}
--]]
function PBUCI.getSection (self, config, section, option, isShow)
	if not self then
		self = PBUCI.new()
	end
	if type(option) == 'boolean' then
		isShow = option
		option = nil
	end

	isShow = isShow or false
	local obj = nil
	if option then
		logger.debug(string.format('[PBUCI]Get UCI Section <%s.%s.%s>', config, section, option))
		obj = uci:get(config, section, option)
	else
		logger.debug(string.format('[PBUCI]Get UCI Section <%s.%s>', config, section))
		obj = uci:get_all(config, section)
		if obj and not isShow then
			obj['.name']      = nil
			obj['.type']      = nil
			obj['.anonymous'] = nil
		end
	end

	self.content = obj
	self.parms   = { config, section }
	if option then self.parms[#self.parms+1] = option end
	return self
end

function getSection (config, section, option, isShow)
	return PBUCI:getSection(config, section, option, isShow)
end

function getUCISection (config, section, option, isShow)
	return PBUCI:getSection(config, section, option, isShow):get()
end

--[[
	批量获取UCI 列表数据

	@since 0.3.0
	@param {String} config	[UCI config]
	@param {String} type	[UCI section type]

	@return {Array}
--]]
function PBUCI.getList (self, config, type, isShow)
	if not self then
		self = PBUCI.new()
	end
	isShow = isShow or false
	local rv = {}
	if not config or not type then
		self.content = rv
		return self
	end
	logger.debug(string.format('[PBUCI]Get UCI List <%s.%s>', config, type))
	uci:foreach(config, type,
		function (section)
			rv[#rv+1]     = getUCISection(config, section['.name'])
			rv[#rv].wname = section['.name']
			if not isShow then
				rv[#rv]['.name']      = nil
				rv[#rv]['.type']      = nil
				rv[#rv]['.anonymous'] = nil
			end
		end)
	if #rv == 0 then
		logger.debug(string.format('[PBUCI]Get UCI List <%s.%s>', config, type))
	end

	self.content = rv
	self.parms   = { config, section }
	return self
end

function getList (config, type, isShow)
	return PBUCI:getList(config, type, isShow)
end

function getUCIList (config, type, isShow)
	return PBUCI:getList(config, type, isShow):get()
end

--[[
	批量设置UCI Section 数据

	@since 0.3.0
	@param {String} config	[UCI config]
	@param {String} section	[UCI section]
	@param {Table} Object	[Value Object]

--]]
function PBUCI.setSection (self, config, section, values)
	if not self then
		self = PBUCI.new()
	end
	if not config or not section or not values then
		return false
	end
	if 'string' ~= type(config) then
		return false
	end
	if 'string' ~= type(section) then
		return false
	end
	if 'table' == type(values) then
		for key, value in pairs(values) do
			if value then
				logger.debug(string.format('[PBUCI]Set UCI Section <%s.%s.%s>', config, section, key))
				uci:set(config, section, key, value)
			end
		end
	end
	if 'string' == type(values) then
		logger.debug(string.format('[PBUCI]Set UCI Section <%s.%s>', config, section))
		uci:set(config, section, values)
	end
	logger.debug(string.format('[PBUCI]Set UCI Commit <%s>', config))
	uci:commit(config)

	self.parms = { config, section }

	return self
end

function setSection (config, section, values)
	return PBUCI:setSection (config, section, values)
end

function setUCISection (config, section, values)
	if PBUCI:setSection (config, section, values) then
		return true
	end
	return false
end

--[[
	新添UCI Section 数据

	@since 0.3.0
	@param {String} config	[UCI config]
	@param {String} section	[UCI section]
	@param {Table} values	[Value Object]

--]]
function PBUCI.addSection (self, config, section, values)
	if not self then
		self = PBUCI.new()
	end
	if not config or not section then
		return false
	end

	local wname = uci:add(config, section)
	uci:commit(config)
	logger.debug(string.format('[PBUCI]Add UCI Section <%s.%s>', config, section))

	if values then
		setUCISection(config, wname, values)
	end

	return wname
end

function addUCISection (config, section, values)
	return PBUCI:addSection(config, section, values)
end

--[[
	删除UCI Section 数据

	@since 0.3.0
	@param {String} config	[UCI config]
	@param {String} section	[UCI section]
	@param {Table} values	[Value Object]

--]]
function PBUCI.removeSection (self, config, section, values)
	if not config or not section then
		return false
	end

	if values then
		if type(values) == "string" then
			values = { values }
		end
		if type(values) == 'table' then
			for _, value in ipairs(values) do
				logger.debug(string.format('[PBUCI]Remove UCI Section <%s.%s.%s>', config, section, value))
				uci:delete(config, section, value)
			end
		end
	else
		logger.debug(string.format('[PBUCI]Remove UCI Section <%s.%s>', config, section))
		uci:delete_all(config, section)
	end
	uci:commit(config)

	return wname
end

function removeUCISection (config, section, values)
	return PBUCI:removeSection(config, section, values)
end

function PBUCI.delSection ( ... )
	return PBUCI.removeSection(...)
end

function delUCISection ( ... )
	return removeUCISection(...)
end

--[[
	提交UCI Section 数据

	@since 0.3.0
	@param {String} config	[UCI config]
	@param {String} section	[UCI section]
	@param {Table} Object	[Value Object]

--]]
function PBUCI.commit (self, config, callback)
	if not self then
		self = PBUCI.new()
	end
	if not config then
		return false
	end
	if 'string' ~= type(config) and 'function' ~= type(config) then
		return false
	end
	if 'function' == type(config) then
		callback = config
		config   = nil
	end
	if 'function' ~= type(callback) then
		callback = nil
	end
	if not config then
		if #self.parms > 0 then
			config = self.parms[1]
		else
			return false
		end
	end

	logger.debug(string.format('[PBUCI]Set UCI Commit <%s>', config))
	uci:commit(config)
	self.parms = { config, section }
	if callback then
		callback()
	end

	return self
end

function commit (config, callback)
	if PBUCI:commit (config, callback) then
		return true
	end
	return false
end

--[[
	检查UCI Section 是否存在

	@since 0.3.0
	@param {String} config	[UCI config]
	@param {String} section	[UCI section]
	@param {String} key		[UCI key]

--]]
function exists (config, section, key)
	if not config then return false end
	if not section then return false end

	if not uci:get(config, section) then
		return false
	end
	if key and not uci:get(config, section, key) then
		return false
	end

	return true
end

function existsSection (config, section, key)
	return exists(config, section, key)
end

function existsUCISection (config, section, key)
	return exists(config, section, key)
end


function checkWname (wname, config, T)
	if not wname then
		return nil
	end

	logger.debug(string.format('[PBUCI]checkWname \'%s\' from <%s.%s>', wname, config, T))
	local isExist = false
	local _type = uci:get(config, wname)
	if _type and _type == T then
		isExist = true
	end

	if isExist then
		return wname
	end
	return nil
end

function PBUCI.each (self, callback)
	if not self then
		self = PBUCI.new()
	end
	if not callback and 'function' ~= type(callback) then
		callback = function () end
	end
	for key, value in ipairs(self.content or {}) do
		callback(key, value)
	end

	return self
end

function PBUCI.is (self, select, callback)
	if not self then
		self = PBUCI.new()
	end
	if #self.content == 0 then
		self.content = { self.content }
	end

	if not callback or 'function' ~= type(callback) then
		callback = function () end
	end

	local rv = { }

	self:each(function (index, item)
		local isSame = true
		for key, value in pairs(select or {}) do
			if not item[key] or item[key] ~= value then
				isSame = false
			end
		end
		if isSame then
			rv[#rv+1] = item
			callback(index, item)
		end
	end)

	self.content = rv
	return self
end
