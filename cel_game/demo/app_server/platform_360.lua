local skynet = require "skynet"
require "skynet.manager"
local configtable = require "configtable"
local platform = configtable.get "PLATFORM"
local httpc = require "http.httpc"

local command = {}

--must return {user="xxxxxxxx"}
function command.login(data)
	return {error=ERRORCODE.PLATFORM_CALL_FAILED}
end

function command.pay(data)
	return ""
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register ".platform_360"
end)
