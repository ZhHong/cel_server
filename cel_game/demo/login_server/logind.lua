local login = require "snax.kyloginserver"
local crypt = require "crypt"
local skynet = require "skynet"
local util = require "util"
local jsonpack = require "jsonpack"
local msgserverlist = require "config_msgserverlist"

local server = {
	host = "0.0.0.0",
	port = 8101,
	multilogin = false,	-- disallow multilogin
	name = "login_server",
}

local listen_port = ...
server.port = listen_port

local server_list = {}
local servername_list = {}
local user_online = {}
local user_login = {}

-- step2 check client send token
function server.auth_handler(token)
	-- the token is base64(user)@base64(server):base64(password)

	--[[
	local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	password = crypt.base64decode(password)
	--]]
	data = jsonpack.unpack(token)

	--for client test
	if data.platform == "test" then
		return data.server, data.platform..data.user
	end
	-- chose msg server to login
	local result, err = util.get_msg_data(util.call_route(".la_route", nil, 301, data))
	if not result then error(err) end

	return data.server, data.platform..result.user
end

-- login handler after authh_handler
-- if not multilogin this function only be call once
function server.login_handler(server, uid, secret)
	print(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))
	
	--random msgserver
	local random_index = math.random(#servername_list)
	if not servername_list[random_index] then
		error("msgserver not found!")
	end

	local call_servername = servername_list[random_index]

	local call_msgserver = assert(server_list[call_servername], "msgserver not found!")

	-- only one can login, because disallow multilogin
	local last = user_online[uid]
	if last then
		util.call_route(".lm_route", last.address, 101, {service="."..last.address, uid=uid, subid=last.subid})
	end
	if user_online[uid] then
		error(string.format("user %s is already online", uid))
	end

	local result = util.call_route(".lm_route", call_servername, 102, {service="."..call_servername, uid=uid, secret=secret})
	if not result then
		error(".lm_route failed")
	end

	local subid, err = util.get_msg_data(result)

	if not subid then
		error(err)
	end

	user_online[uid] = { address = call_servername, subid = subid }

	return string.format("%s:%d:%s:%d", call_msgserver.client_host, call_msgserver.client_port, uid, subid)
end

-- use to recive inside skynet commond
local CMD = {}

function CMD.register_gate(data)
	local servername = data.servername
	if not msgserverlist[servername] then
		error("msgserver "..servername.." not found!")
	end

	if not server_list[servername] then
		server_list[servername] = msgserverlist[servername]
		server_list[servername].lasttick = os.time()
		servername_list[#servername_list+1] = servername
	else
		server_list[servername].lasttick = os.time()
	end

	for i = #servername_list, 1, -1 do
		local check_name = servername_list[i]
    	if os.time() - server_list[check_name].lasttick > 60 then
    		skynet.error(string.format("%s idle more than 60 seconds",check_name))
        	table.remove(servername_list, i)
        	server_list[check_name] = nil
        end
    end
end

function CMD.logout(data)
	local uid = data.uid
	local subid = data.subid
	local u = user_online[uid]
	if u then
		print(string.format("%s@%s is logout", uid, u.address))
		user_online[uid] = nil
	end
end

function CMD.web_dispatch(data)
	skynet.error(jsonpack.pack(data))
	return true
end

function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f(...)
end

login(server)
