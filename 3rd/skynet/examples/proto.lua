local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

handshake 1 {
	response {
		msg 0  : string
	}
}

get 2 {
	request {
		what 0 : string
	}
	response {
		result 0 : string
	}
}

set 3 {
	request {
		what 0 : string
		value 1 : string
	}
}

userinfo 4 {
	request {
		who 0 : integer
	}
	response {
		ok 0 : integer
		uid 1 : integer
		uname 1: string
		sex 3 : integer
		level 4 : integer
		exp 5 : integer
		gold 6 : integer
	}
}

quit 5 {}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}
]]

return proto
