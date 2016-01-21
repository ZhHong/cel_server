local skynet = require "skynet"
require "skynet.manager"
local configtable = require "configtable"
local platform = configtable.get "PLATFORM"
local httpc = require "http.httpc"
local jsonpack = require "jsonpack"
local md5 = require "md5"
local util = require "util"

local platform_name = "ky"

local command = {}

--must return {user="xxxxxxxx"}
function command.login(data)
	local appid = platform[platform_name].appid
	local secrect = platform[platform_name].secrect
	local host = platform[platform_name].host
	local dir = platform[platform_name].dir

	local form = {}
	form.appid = appid
	form.token = data.token
	form.sign = string.lower(md5.sumhexa(form.appid..form.token..secrect))
	
	local body = {}
	for k,v in pairs(form) do
		table.insert(body, string.format("%s=%s",util.escape(k),util.escape(v)))
	end

	local header = {}
	local status, body = httpc.get(host, dir.."?"..table.concat(body , "&"), header)

	--post
	--[[
	local header = {}
	local status, body = httpc.post(host, dir, form, header)
	--]]


	--[[
	print("[header] =====>")
	for k,v in pairs(header) do
		print(k,v)
	end
	print("[body] =====>", status)
	print(body)
	--]]

	if status ~= 200 then
		return {error=ERRORCODE.PLATFORM_CALL_FAILED}
	else
		ret_data = jsonpack.unpack(body)
		if not ret_data.error or not ret_data.uid then
			return {error=ERRORCODE.PLATFORM_CALL_FAILED}
		elseif ret_data.error ~= 0 then
			return {error=data.error}
		elseif ret_data.uid ~= data.user then
			return {error=PLATFORM_UID_FAILED}
		else
			return {user=ret_data.uid}
		end
	end

	return {error=ERRORCODE.PLATFORM_CALL_FAILED}
end

function command.pay(data)
	data.platform_name = platform_name
	data.platform_method = "pay"
	local result = util.call_route(".al_route", "login_server", 401, data)
	if result then
		return "success"
	else
		return "fail"
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register ".platform_ky"
end)
