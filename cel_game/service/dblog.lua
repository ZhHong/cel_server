local skynet = require "skynet"
require "skynet.manager"
local mongo = require "mongo"
local logdblist = require "config_logdblist"

local db = {}
local log_db = {}

local command = {}

function command.INFO(server_id, collection_name, data)
	if not log_db[server_id] then
		skynet.error(string.format("mongodb not found. server_id = %d", server_id))
		return
	end
	local ret = log_db[server_id][collection_name]:safe_insert(data);
	if ret and ret.n == 1 then
		return
	else
		skynet.error(string.format("mongodb error. error = %d. collection = %s. data = %s", ret.n, collection_name, data))
	end
end

skynet.start(function()
	for	k, v in	pairs(logdblist) do
		db[k] = mongo.client(v)
		for i= 1, #v.list do
			log_db[v.list[i]] = db[k]:getDB(v.db..tostring(v.list[i]))
		end  		
  	end

	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		f(...)
	end)
	skynet.register ".dblog"
end)
