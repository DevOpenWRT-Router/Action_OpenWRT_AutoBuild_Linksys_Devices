local logger = require "luci.pb.PBLog"

module('luci.pb.PBUtil', package.seeall)

function index ()
end

--[[
	获取UCI Section 数据

	@since 0.3.0
	@see luci.pb.PBUCI.getUCISection
--]]
function getUCISection (config, section, option, isShow)
	local PBUCI = require('luci.pb.PBUCI')
	return PBUCI.getUCISection(config, section, option, isShow)
end
--[[
	批量获取UCI 列表数据

	@since 0.3.0
	@see luci.pb.PBUCI.getUCIList
--]]
function getUCIList (config, type, isShow)
	local PBUCI = require('luci.pb.PBUCI')
	return PBUCI.getUCIList(config, type, isShow)
end
--[[
	批量设置UCI Section 数据

	@since 0.3.0
	@see luci.pb.PBUCI.setUCISection
--]]
function setUCISection (config, section, values)
	local PBUCI = require('luci.pb.PBUCI')
	return PBUCI.setUCISection(config, section, values)
end

--[[
	批量获取表单数据

	@since 0.3.0
	@param {String|Array} name|names

	@return {Array} Values
--]]
function getFormValue (value)
	local rv = {}
	if type(value) == 'string' then
		value = { value }
	end
	if type(value) == 'table' then
		for _, v in ipairs(value) do
			if type(v) == 'string' then
				rv[v] = luci.http.formvalue(v) or nil
				if rv[v] and 'string' == type(rv[v]) then
					logger.debug(string.format('[PBUtil]Get Formvalue <%s -> %s>', v, rv[v]))
					if string.len(rv[v]) == 0 then
						rv[v] = nil
					else
						for key, value in pairs({
							_23 = '#',
							_25 = '%',
							_26 = '&',
							_2B = '+',
							_2F = '/',
							_3F = '?',
							_3D = '='
						}) do
							if rv[v]:match(key) then
								rv[v] = rv[v]:gsub(key:gsub('_', '%%'), value)
							end
						end
					end
				end
			end
		end
	end
	return rv
end

--[[
	合并Table(Object)

	@since 0.3.0
	@param {Object} dst
	@param {Object} src

	@return {Object} obj
--]]
function mergeTable (obj1, obj2)
	if not obj1 or not obj2 then
		return obj1
	end
	if type(obj1) ~= 'table' or type(obj2) ~= 'table' then
		return obj1
	end

	for key, value in pairs(obj2) do
		obj1[key] = value
	end

	return obj1
end

function checkWname (wname, config, T)
	local PBUCI = require('luci.pb.PBUCI')
	return PBUCI.checkWname(wname, config, T)
end

--[[
	获取反馈组件

	@since 0.3.0

	@return {Module}
--]]
function message ()
	local msg = require('luci.pb.code')
	return msg
end

--[[
	获取检查组件

	@since 0.3.0

	@return {Module}
--]]
function checker ()
	local checker = require('luci.pb.checker')
	return checker
end
