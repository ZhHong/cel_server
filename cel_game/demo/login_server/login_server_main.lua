local skynet = require "skynet"
local configtable = require "configtable"
local logdblist = require "config_logdblist"

-- get configer sets
local max_client = tonumber(skynet.getenv "maxclient")
local listen_port1 = tonumber(skynet.getenv "listenport")
local listen_port2 = tonumber(skynet.getenv "systemport")

skynet.start(function()
	--config init
	configtable.init()

	--filelog
	skynet.newservice("filelog")

	--dblog
	skynet.newservice("dblog")

	--lm route
	skynet.newservice("lm_route")

	--la route
	skynet.newservice("la_route")

	--for msgserver connect
	local watchdog = skynet.newservice("watchdog")
	
	skynet.call(watchdog, "lua", "start", {
		port = listen_port2,
		maxclient = max_client,
		nodelay = true,
	})
	print("for msgserver/appserver connect listen On", listen_port2)

	--for client connect
	skynet.newservice("logind", listen_port1)
	
	print("for client connect listen On", listen_port1)

	
	skynet.exit()
end)
