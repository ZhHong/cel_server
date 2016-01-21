local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"

local mysql_host, mysql_port, mysql_db, mysql_user, mysql_pwd, mysql_max_psz = ...

local conf = {
	host=mysql_host,
	port=mysql_port,
	database=mysql_db,
	user=mysql_user,
	password=mysql_pwd,
	max_packet_size = tonumber(mysql_max_psz)
}

local db
local command = {}

function command.LOG(table_name, platform, server_id, event_type, uid, playerid, level, num_params, str_params)
	local sql = string.format("call insert_log('%s', '%s', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')", 
								table_name, platform, server_id, event_type, uid, playerid, level, 
								num_params[1], num_params[2], num_params[3], num_params[4], num_params[5], num_params[6], num_params[7], num_params[8], num_params[9], num_params[10], 
								str_params[1], str_params[2], str_params[3], str_params[4], str_params[5], str_params[6], str_params[7], str_params[8], str_params[9], str_params[10])
	local res = db:query(sql)
	if res["badresult"] ~= nil then
		skynet.error(string.format("mysql error. error = %s, errid = %d sql = %s", res["err"], res["errno"], sql))
	end
end

function command.CREATETABLE(table_name)
	local sql = string.format("call create_table('%s')", table_name)
	local res = db:query(sql)
	if res["badresult"] ~= nil then
		skynet.error(string.format("mysql error. error = %s, errid = %d sql = %s", res["err"], res["errno"], sql))
	end
end

skynet.start(function()
	db = mysql.connect(conf)
	if not db then
		skynet.error("mysql failed to connect")
	end
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		f(...)
	end)
	skynet.register ".mysqllog"
end)
