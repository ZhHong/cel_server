local skynet = require "skynet"
require "skynet.manager"
local jsonpack = require "jsonpack"
local loginserverlist = require "config_loginserverlist"
local routechannel = require "routechannel"

local command = {}
local serverlist = {}
local serverlist_count = 0

function command.ROUTE(server_name, data)
	if not serverlist[server_name] then
		error("loginserver not found!")
	end
	return serverlist[server_name]:send(data)
end

skynet.start(function()
	for	k, v in	pairs(loginserverlist) do
  		serverlist[k] = routechannel.connect(v)
  		serverlist_count = serverlist_count + 1
  	end

	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register ".ml_route"
end)

