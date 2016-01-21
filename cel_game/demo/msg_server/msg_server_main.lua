local skynet = require "skynet"
local configtable = require "configtable"

local max_client = tonumber(skynet.getenv "maxclient")
local listen_port1 = tonumber(skynet.getenv "listenport")
local listen_port2 = tonumber(skynet.getenv "systemport")
local server_name = skynet.getenv "servername"

skynet.start(function()
	--config init
	configtable.init()

	--timer
	skynet.newservice("timer", server_name)

	--ml route
	skynet.newservice("ml_route")

	--for msgserver connect
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = listen_port2,
		maxclient = max_client,
		nodelay = true,
	})
	print("for msgserver connect listen On", listen_port2)

	--for client connect
	local gate = skynet.newservice("gated")

	skynet.call(gate, "lua", "open" , {
		port = listen_port1,
		maxclient = max_client,
		servername = server_name,
	})
	print("for client connect listen On", listen_port1)

	skynet.exit()
end)


