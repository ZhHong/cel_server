local skynet = require "skynet"
local socket = require "socket"
local socketchannel = require "socketchannel"
local netpack = require "netpack"

local table = table
local string = string

local routechannel = {}
local command = {}
local meta = {
	__index = command,
	-- DO NOT close channel in __gc
}

local __id = 0

local function get_request_id()
	local request_id = __id + 1
	if request_id > 1999999999 then
		request_id = 1
	end
	__id = request_id
	return request_id
end

---------- response
local function dispatch_reply(fd)

	local result = fd:readline '\r\n'

	local ret_str = string.sub(result,3)

	--get reply_id
	local id_str, after_str = string.match(ret_str, "(%d+)%+(.*)")

	return tonumber(id_str), true, after_str

end
-------------------
local function server_login(token)
	if token == nil then
		return nil
	end
	return function(so)
		if token then
			local request_id = get_request_id()
			so:request(netpack.pack_string(tostring(request_id).."+"..token), request_id)
		end
	end
end

function routechannel.connect(server_conf)
	local channel = socketchannel.channel {
		host = server_conf.host,
		port = server_conf.port,
		response = dispatch_reply,
		--auth = server_login(server_conf.auth),
	}

	-- try connect first only once
	--channel:connect(true)
	return setmetatable( { channel }, meta )
end

function command:disconnect()
	self[1]:close()
	setmetatable(self, nil)
end

function command:send(data)
	local fd = self[1]

	local request_id = get_request_id()

	return fd:request(netpack.pack_string(tostring(request_id).."+"..data), request_id)
end

return routechannel
