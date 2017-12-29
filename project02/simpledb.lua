local skynet = require "skynet"
local redis = require "redis"
require "skynet.manager"	-- import skynet.register

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0,
	--auth = "xwx"
}

local db = {}

local command = {}

function command.GET(key)
	return db:get(key)
end

function command.SET(key, value)
	db:set(key, value)
end

skynet.start(function()
	db = redis.connect(conf)
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "SIMPLEDB"
end)
