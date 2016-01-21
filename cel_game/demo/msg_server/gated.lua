local msgserver = require "snax.kymsgserver"
local crypt = require "crypt"
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"

local server = {}
local users = {}
local username_map = {}
local internal_id = 0
local agent_pool = {}


local function add_agent(num)
	for i = 1, num do
		table.insert(agent_pool, skynet.newservice("msgagent"))
	end
end

local function get_agent()
	if #agent_pool == 0 then
		--must be 1
		add_agent(1)
	end
	return table.remove(agent_pool)
end

local function return_agent(agent)
	if agent then
		table.insert(agent_pool, agent)
	end
end

function server.force_kick(uid)
	local u = users[uid]
	if u then
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		pcall(skynet.call, u.agent, "lua", "logout")
	end
end

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(data)
	local uid = data.uid
	local secret = data.secret

	if users[uid] then
		server.force_kick(uid)
		error(string.format("%s is already login", uid))
	end

	internal_id = internal_id + 1
	local username = msgserver.username(uid, internal_id, "unknown")

	-- you can use a pool to alloc new agent
	local agent = get_agent()
	local u = {
		username = username,
		agent = agent,
		uid = uid,
		subid = internal_id,
	}

	-- trash subid (no used)
	skynet.call(agent, "lua", "login", uid, internal_id, secret)

	users[uid] = u
	username_map[username] = u

	msgserver.login(username, secret)

	-- you should return unique subid
	return internal_id
end

-- call by agent
function server.logout_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, "unknown")
		assert(u.username == username)
		msgserver.logout(u.username)
		return_agent(u.agent)
		users[uid] = nil
		username_map[u.username] = nil
	end
	local result = util.call_route(".ml_route", "login_server", 202, {uid=uid, subid=subid})
	if not result then
		skynet.error("server.logout_handler failed!")
	end	
end

-- call by login server
function server.kick_handler(data)
	local uid = data.uid
	local subid = data.subid
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, "unknown")
		assert(u.username == username)
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		pcall(skynet.call, u.agent, "lua", "logout")
	else
		server.logout_handler(uid, subid)
	end

end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	local u = username_map[username]
	if u then
		skynet.call(u.agent, "lua", "afk")
	end
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg, sz)
	local u = username_map[username]
	return skynet.tostring(skynet.rawcall(u.agent, "client", msg, sz))
end

-- call by self (when gate open)
function server.register_handler(name)
	skynet.error("register_handler "..name)
	local servername = name
	--skynet.call(loginservice, "lua", "register_gate", servername, skynet.self())
	local result = util.call_route(".ml_route", "login_server", 201, {servername=servername})
	while not result do
		skynet.sleep(500)
		skynet.error("login server don't start, try again!")
		result = util.call_route(".ml_route", "login_server", 201, {servername=servername})
	end
	skynet.register("."..servername)

	--agent pool
	add_agent( 1024 )
end

msgserver.start(server)

