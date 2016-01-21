local cjson = require "cjson"

local jsonpack = {}

function jsonpack.pack(msg)
	return cjson.encode(msg)
end

function jsonpack.unpack(msg)
	return cjson.decode(msg)
end

return jsonpack