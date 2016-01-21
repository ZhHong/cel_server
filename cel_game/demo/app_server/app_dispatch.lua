local skynet = require "skynet"
require "skynet.manager"
local configtable = require "configtable"
local platform = configtable.get "PLATFORM"

local command = {}

function command.dispatch(data)
	if not data.platform then
		return {error=ERRORCODE.PLATFORM_NOT_FOUND}
	end

	local platform_conf = platform[data.platform]

	if not platform_conf then
		return {error=ERRORCODE.PLATFORM_NOT_FOUND}
	end

	local ok, result = pcall(skynet.call, platform_conf.service, "lua", data.method, data)

	if not ok then
		return {error=ERRORCODE.PLATFORM_CALL_FAILED}
	else
		return result
	end

end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register ".app_dispatch"

end)

