local config_list = {
	["CONSTANT"] = {file= "config_constant", method= "static"},
	["ERRORCODE"] = {file= "config_errorcode", method= "static"},
	["PLATFORM"] = {file= "config_platform", method= "static"},
	["PROTOCOL"] = {file= "config_protocol", method= "share"},
	["PROTO"] = {file= "config_proto", method= "share"},
}
return config_list
