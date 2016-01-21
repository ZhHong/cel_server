local proto = [[
.package {
	type 0 : integer
	session 1 : integer
}
test 1 {
	request {
		data 0 : integer
	}
	response {
		data 0 : integer
	}
}
]]

return proto
