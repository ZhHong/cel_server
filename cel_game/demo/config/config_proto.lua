local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse (require "game.proto")

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}
]]

return proto