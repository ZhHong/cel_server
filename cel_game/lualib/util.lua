local skynet = require "skynet"
local jsonpack = require "jsonpack"
--  lua class like
local util = {}

function util.call_route(route_name, server_name, msg_id, data)
    local msg_data = tostring(msg_id).."+"..jsonpack.pack(data)
    local ok, result 
    if server_name then
    	ok, result = pcall(skynet.call, route_name, "lua" , "ROUTE" , server_name, msg_data)
    else
    	ok, result = pcall(skynet.call, route_name, "lua" , "ROUTE" , msg_data)
    end
    if not ok then
        return false, result
    end
    return result
end

function util.get_msg_data(data)
	if not data then return false, ERRORCODE.ERROR end
	local msg_id, msg_data = string.match(data, "(%d+)%+(.*)")
	local result = jsonpack.unpack(msg_data)
	if not result then
		return false, ERRORCODE.ERROR
	end
	if type(result) == "table" and result.error and result.error ~= ERRORCODE.SUCCESS then
		return false, result.error
	end
	return result
end

function util.escape(s)
	return (string.gsub(s, "([^A-Za-z0-9_])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

function util.fileloginfo(filename, data)
	skynet.send(".filelog", "lua", "INFO", "../../logs/"..filename.."_%s.log", data)
end

function util.dbloginfo(server_id, tablename, data)
	skynet.send(".dblog", "lua", "INFO", server_id, tablename, data)
end
		
return util