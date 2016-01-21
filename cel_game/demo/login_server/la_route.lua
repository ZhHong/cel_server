local skynet = require "skynet"
require "skynet.manager"
local jsonpack = require "jsonpack"
local appserverlist = require "config_appserverlist"
local routechannel = require "routechannel"

local command = {}
local serverlist = {}

function command.ROUTE(data)
	local random_index = math.random(#serverlist)
	if not serverlist[random_index] then
		error("appserver not found!")
	end
	return serverlist[random_index]:send(data)
end

skynet.start(function()
	for	k, v in	pairs(appserverlist) do
  		serverlist[k] = routechannel.connect(v)
  	end

	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register ".la_route"
end)

