local skynet = require "skynet"
require "skynet.manager"
local configtable = require "configtable"
local platform = configtable.get "PLATFORM"

local command = {}

function command.dispatch(method, path, param)
	local platform_name = string.gsub(path, "/", "")

	local platform_conf = platform[platform_name]

	if not platform_conf then
		error("platform not found! name = "..platform_name)
	end

	local ok, result = pcall(skynet.call, platform_conf.service, "lua", method, param)

	if not ok then
		error("platform call failed!")
	else
		return result
	end

end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register ".web_dispatch"

end)

