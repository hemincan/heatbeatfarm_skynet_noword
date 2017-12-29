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

function command.DEL( key )
	db:del(key)
end

function command.HVALS( hkey )--获取哈兮中所有值
	return db:hvals(hkey)
end

function command.HLEN(hkey)--获取哈兮字段数
	return db:hlen(hkey)
end

function command.HSET(hkey,key,value)--设置哈兮字段字符串值
	db:hset(hkey,key,value) 
end

function command.HDEL(hkey, ...)--删除一个或多个哈兮字段
	db:hdel(hkey,...)
end

function command.HEXISTS(hkey,key)--判断一个哈兮字段存在 与否
	return db:hexists(hkey,key)
end

function command.HGETALL(hkey)--
	return db:hgetall(hkey)
end

function command.HGET(hkey,key)--获取指定键哈兮字段值
	return db:hget(hkey,key)
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
