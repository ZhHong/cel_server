local skynet = require "skynet"
local util = require "util"

local server_name = ...

local function timer( ... )
	local result = util.call_route(".ml_route", "login_server", 201, {servername=server_name})
	if not result then
		skynet.error("login server don't start, try again!")
	end
end

skynet.start(function()
    skynet.fork(function()
        while true do
        	skynet.sleep(3000)
            timer()
        end
    end)
end)