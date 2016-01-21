local skynet = require "skynet"
local queue = require "skynet.queue"
local sproto = require "sproto"
local configtable = require "configtable"

local host
local send_request
local protocol
local proto
local cs = queue() 

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
}

local gate
local userid, subid

local CMD = {}

local FUNCS = {}

function CMD.login(source, uid, sid, secret)
	-- you may use secret to make a encrypted data stream
	skynet.error(string.format("%s is login", uid))
	gate = source
	userid = uid
	subid = sid
	-- you may load user data from database
end

local function logout()
	if gate then
		skynet.call(gate, "lua", "logout", userid, subid)
	end
	--skynet.exit()
end

function CMD.logout(source)
	-- NOTICE: The logout MAY be reentry
	skynet.error(string.format("%s is logout", userid))
	logout()
end

function CMD.afk(source)
	-- the connection is broken, but the user may back
	skynet.error(string.format("AFK"))
end

function FUNCS.test( data )
	return true, {data=data.data}
end

function FUNCS.dispatch( data )
	return false, {}
end


local function dispatch(func, response, ...)
	local ok, result = FUNCS[func](...)
	if ok then
		local str = response(result)
		skynet.error(string.format("msgagent response. userid = %s, str = %s", userid, str))
		skynet.ret(str)
	end
end

skynet.start(function()
	protocol = configtable.get "PROTOCOL"
	proto = configtable.get "PROTO"
	host = sproto.new(proto.c2s):host "package"
	send_request = host:attach(sproto.new(proto.s2c))
	-- If you want to fork a work thread , you MUST do it in CMD.login
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
		skynet.ret(skynet.pack(f(source, ...)))
	end)

	skynet.dispatch("client", function(_,_, type, name, args, response)
		if type == "REQUEST" then
			local msg_protocol = protocol[name]
			if not msg_protocol then
				error "doesn't support REQUEST"
			end

			skynet.error(string.format("msgagent dispatch. userid = %s, name = %s", userid, name))
			-- call check fun
			local func = msg_protocol.func or "dispatch"

			cs(dispatch, func, response, args)

		else
			assert(type == "RESPONSE")
			error "doesn't support RESPONSE"
		end
	end)
end)
