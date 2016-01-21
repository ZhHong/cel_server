local skynet = require "skynet"
local jsonpack = require "jsonpack"
local netpack = require "netpack"
local socket = require "socket"
local configtable = require "configtable"
local util = require "util"

local CMD = {}

local client_fd

local function response_client(session_id, msg_id, data)
	socket.write(client_fd, netpack.pack(tostring(session_id).."+"..tostring(msg_id).."+"..jsonpack.pack(data).."\r\n"))
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return skynet.tostring(msg,sz)
	end,
	dispatch = function (_, _, data)
		print(data)
		local session_id, msg_id, msg_data = string.match(data, "(%d+)%+(%d+)%+(.*)")
		util.fileloginfo("test", {session_id=session_id, msg_id=msg_id, msg_data=msg_data})
		--util.dbloginfo(0, "test", {session_id=session_id, msg_id=msg_id, msg_data=msg_data})

		local protocol = configtable.get("PROTOCOL")
		local msg_protocol = protocol[tostring(msg_id)]
		if not msg_protocol then
			response_client(session_id, msg_id, {error=ERRORCODE.PARAM_ERROR})
			return
		end
		local ok, result = pcall(skynet.call, msg_protocol.service, "lua", msg_protocol.func, jsonpack.unpack(msg_data))
		if ok then
			response_client(session_id, msg_id, result)
		else
			response_client(session_id, msg_id, {error=ERRORCODE.FUNCTION_ERROR})
		end
	end
}

function CMD.start(gate , fd)
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
