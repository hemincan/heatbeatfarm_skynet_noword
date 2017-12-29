local skynet = require "skynet"
local queue = require "skynet.queue"
local lock
local CMD = {}
local yesterdatelist = {}--昨日日羸金币
local yesterdatealllist = {}--昨日总金币
require "skynet.manager"	-- import skynet.register
-----------------------
--getyesdaylist
--返回
--{ action="yesdaylist",list={{},{},{},{}}}
--返回
----getyesdayalllist
--{ action="yesdayalllist",list={{},{},{},{}}}
--
-----------------------
function getDataDayFromDB(  )
	local data = {}
	--查数据库

	-- for i=1,10 do
	-- 	local t = {"test"..i,i*10}
	-- 	table.insert(data,t)
	-- end
	data=skynet.call("mysqldb","lua","selectrankdaily")
	return data
end
function getDataAllFromDB(  )
	local data = {}
	--查数据库

	-- for i=1,10 do
	-- 	local t = {"testall"..i,i*10}
	-- 	table.insert(data,t)
	-- end
	data=skynet.call("mysqldb","lua","selectranktotal")
	return data
end
function getDataDayFromCache(  )
	
	--查redis,目前没有查redis,留着一个接口
	return yesterdatelist
end
function getDataAllFromCache(  )
	
	--查redis目前没有查redis,留着一个接口
	return yesterdatealllist
end
function CMD.zerotime(  )--0点同步
	lock(
	function (  )
		--查数据库,得到新的值
		print("查数据库,得到新的值")
		yesterdatelist=getDataDayFromDB()
		yesterdatealllist=getDataAllFromDB()
		--把新的值存到缓存		
	end
	)

end
function CMD.getyesdaylist(  )--昨天日羸排行
	--查缓存与0点同步锁起来
	local x={}
	lock(
	function (  )
		x.list = getDataDayFromCache(  )
		x.action="yesdaylist"
	end
	)
	return x
end
function CMD.getyesdayalllist(  )--昨天总金额排行
	--查缓存,与0点同步锁起来
	local x={}
	lock(
	function (  )
		x.list = getDataAllFromCache(  )
		x.action="yesdayalllist"
	end
	)
	return x
end
skynet.start(function (  )
	lock = queue()
	--重启
	CMD.zerotime(  )
	skynet.dispatch("lua",function ( _,_,cmd,... )
		local f = CMD[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		end
	end)
	skynet.register "RANKINGLIST"
end) 