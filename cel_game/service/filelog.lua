local log_file = require "logging.file"

local skynet = require "skynet"
require "skynet.manager"

local loggers = {}

local command = {}

local function get_logger(filename, reset)
	if loggers[filename] then
		if reset then
			loggers[filename] = nil
		else
			return loggers[filename]
		end
	end
	assert(not loggers[filename])
	local logger = log_file(filename, "%Y-%m-%d")	
	loggers[filename] = logger
	return logger
end

function command.INFO(filename, data)
	local logger = get_logger(filename)
	if not logger:info(data) then
		logger = get_logger(filename, true)
		logger:info(data)
	end
end

function command.DEBUG(filename, data)
	logger = get_logger(filename)
	if not logger:debug(data) then
		logger = get_logger(filename, true)
		logger:debug(data)
	end
end

function command.ERROR(filename, data)
	logger = get_logger(filename)
	if not logger:error(data) then
		logger = get_logger(filename, true)
		logger:error(data)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		f(...)
	end)
	skynet.register ".filelog"
end)
