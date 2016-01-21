local skynet = require "skynet"
local sharedata = require "sharedata"
local configlist
local configdata = {}
local configtable = {}

function configtable.init()
	if configlist then 
		return 
	end
	configlist = require "config_list"
	for k, v in pairs(configlist) do
		if v.method == "share" then
			local file = require(v.file)
			skynet.error(string.format("load %s into sharedata ... name is %s ...", v.file, k))
			sharedata.new(k, file)
		end
	end
end

function configtable.get(config_name)
	if not configlist then 
		configlist = require "config_list"
	end
	local config = configlist[config_name]
	if config then
		if config.method == "share" then
			if not configdata[config_name] then
				configdata[config_name] = sharedata.query(config_name)
				skynet.error(string.format("load %s into configdata(share) ... name is %s ...", config.file, config_name))
			end
			return configdata[config_name]
		elseif config.method == "static" then
			if not configdata[config_name] then
				configdata[config_name] = require(config.file)
				skynet.error(string.format("load %s into configdata(static) ... name is %s ...", config.file, config_name))
			end
			return configdata[config_name]
		else
			return nil
		end
	else
		return nil
	end
end

return configtable