local skynet = require "skynet"
require "skynet.manager"
local jsonpack = require "jsonpack"
local msgserverlist = require "config_msgserverlist"
local routechannel = require "routechannel"

local command = {}
local serverlist = {}

function command.ROUTE(server_name, data)
	if not serverlist[server_name] then
		error("msgserver "..server_name.." not found!")
	end
	return serverlist[server_name]:send(data)
end

skynet.start(function()
	for	k, v in	pairs(msgserverlist) do
		local conf = {}
		conf.host = v.host
		conf.port = v.login_port
  		serverlist[k] = routechannel.connect(conf)
  	end

	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register ".lm_route"
end)

