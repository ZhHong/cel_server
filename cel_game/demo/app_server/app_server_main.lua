local skynet = require "skynet"
local configtable = require "configtable"

local max_client = tonumber(skynet.getenv "maxclient")
--local listen_port1 = tonumber(skynet.getenv "listenport")
local listen_port2 = tonumber(skynet.getenv "systemport")
local web_port = tonumber(skynet.getenv "webport" or "8001")

skynet.start(function()
	--config init
	configtable.init()

	--al route
	skynet.newservice("al_route")

	--app_dispatch
	skynet.newservice("app_dispatch")

	--platform
	skynet.newservice("platform_ky")
	skynet.newservice("platform_360")

	--for loginserver connect
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = listen_port2,
		maxclient = max_client,
		nodelay = true,
	})
	print("for loginserver connect listen On", listen_port2)

	--web
	skynet.newservice("web", web_port)

	--web_dispatch
	skynet.newservice("web_dispatch")

	skynet.exit()
end)

