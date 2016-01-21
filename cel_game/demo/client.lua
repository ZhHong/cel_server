package.cpath = "../../3rd/skynet/luaclib/?.so;../luaclib/?.so"
package.path = "../../3rd/skynet/lualib/?.lua;./config/?.lua;../lualib/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local crypt = require "crypt"
local sproto = require "sproto"
local sprotoparser = require "sprotoparser"
local jsonpack = require "jsonpack"

local s2cdata = [[
.package {
	type 0 : integer
	session 1 : integer
}
]]

local proto = {}
proto.c2s = sprotoparser.parse(require "game.proto")
proto.s2c = sprotoparser.parse(s2cdata)

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

local fd = assert(socket.connect("127.0.0.1", 8101))

local function writeline(fd, text)
	socket.send(fd, text .. "\n")
end

local function unpack_line(text)
	local from = text:find("\n", 1, true)
	if from then
		return text:sub(1, from-1), text:sub(from+1)
	end
	return nil, text
end

local last = ""

local function unpack_f(f)
	local function try_recv(fd, last)
		local result
		result, last = f(last)
		if result then
			return result, last
		end
		local r = socket.recv(fd)
		if not r then
			return nil, last
		end
		if r == "" then
			error "Server closed"
		end
		return f(last .. r)
	end

	return function()
		while true do
			local result
			result, last = try_recv(fd, last)
			if result then
				return result
			end
			socket.usleep(100)
		end
	end
end

local readline = unpack_f(unpack_line)

local challenge = crypt.base64decode(readline())

local clientkey = crypt.randomkey()
writeline(fd, crypt.base64encode(crypt.dhexchange(clientkey)))
local secret = crypt.dhsecret(crypt.base64decode(readline()), clientkey)

print("sceret is ", crypt.hexencode(secret))

local hmac = crypt.hmac64(challenge, secret)
writeline(fd, crypt.base64encode(hmac))

local token = {
	platform = "test",
	method = "login",
	server = "unknown",
	token = "password",
	user = "hello",
}

local function encode_token(token)
	return jsonpack.pack(token)
	--[[
	return string.format("%s@%s:%s",
		crypt.base64encode(token.user),
		crypt.base64encode(token.server),
		crypt.base64encode(token.pass))
	--]]
end

local etoken = crypt.desencode(secret, encode_token(token))
local b = crypt.base64encode(etoken)
writeline(fd, crypt.base64encode(etoken))

local result = readline()
print(result)
local code = tonumber(string.sub(result, 1, 3))
assert(code == 200)
socket.close(fd)

local msgserver_ip, msgserver_port, uid, subid = string.match(crypt.base64decode(string.sub(result, 5)),"([^:]*):([^:]*):([^:]*):([^:]*)")

print(string.format("login ok, ip= %s, port= %s, uid= %s, subid= %s", msgserver_ip, msgserver_port, uid, subid))

----- connect to game server

local session = 0

local function send_request(name, args)
	session = session + 1
	print(name, args, session)
	local str = request(name, args, session)
	local size = #str + 4
	
	local package = string.pack(">I2", size)..str..string.pack(">I4", session)

	socket.send(fd, package)
	return name, session
end

local function recv_response(v)
	local size = #v - 5
	local content, ok, session = string.unpack("c"..tostring(size).."B>I4", v) 
	return ok ~=0 , content, session
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local readpackage = unpack_f(unpack_package)

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local text = "echo"
local index = 1

print("connect")
local fd = assert(socket.connect(msgserver_ip, tonumber(msgserver_port)))
last = ""

local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(uid), crypt.base64encode(token.server),crypt.base64encode(subid) , index)
local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)


send_package(fd, handshake .. ":" .. crypt.base64encode(hmac))

print(readpackage())
--print("===>",send_request("handshake"))
-- don't recv response
-- print("<===",recv_response(readpackage()))

print("disconnect")
socket.close(fd)

index = index + 1

print("connect again")
if msgserver_ip == "" then
	msgserver_ip = "127.0.0.1"
end
local fd = assert(socket.connect(msgserver_ip, tonumber(msgserver_port)))
last = ""

local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(uid), crypt.base64encode(token.server),crypt.base64encode(subid) , index)
local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)

send_package(fd, handshake .. ":" .. crypt.base64encode(hmac))

print(readpackage())

---[[
print("===>",send_request("test", { data = 30001 }))
local flag, msg = recv_response(readpackage())
if flag == true then
	local type, session, args = host:dispatch(msg)
	print(type, session, args)
	if type == "RESPONSE" then
		for k,v in pairs(args) do
			print("key: ", k)
			print("vaule: ", v)
		end
	end
end
--]]
print("disconnect")
socket.close(fd)

