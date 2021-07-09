local logger = require "luci.pb.PBLog"

module('luci.pb.PBCommand', package.seeall)

--[[
	(批量)运行Command

	@since 0.3.0
	@param {Array} Commands

	@return {Array}
--]]
function run (commands)
	if not commands then return false end
	if 'string' == type(commands) then
		commands = { commands }
	end
	if 'table' ~= type(commands) then
		return commands
	end
	for k, v in ipairs(commands) do
		logger.debug(string.format('[PBCommand]Run Command `%s`', v))
		commands[k] = luci.sys.exec(v)
	end

	return commands
end

--[[
	获取Command 的返回信息

	@since 0.3.0
	@param {String} Command

	@return {Array}
--]]
function get (command)
	local bwc = io.popen(command)
	local rv  = {}

	if bwc then
		local ln
		logger.debug(string.format('[PBCommand]Get Command `%s`', command))
		repeat
			ln = bwc:read("*l")
			if not ln then break end

			rv[#rv+1] = ln
		until not ln
	end

	return rv
end
