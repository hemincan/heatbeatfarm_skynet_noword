local skynet = require "skynet"
local cjson = require "cjson"
local json = cjson.new()
local CMD = {}

function onehour(  )
	
end

function getupdatetime(  )
	local time=os.date("%X")
	local h1,m1,s1 = string.match(time,"(%d+):(%d+):(%d+)")
	local h2=24
	local time1 = h1 * 3600 + m1 * 60 + s1
	local time2 = h2 * 3600 
	return  time2-time1
end


function oneday( daytime )
	skynet.timeout(daytime*100, function()--(time2-time1)*100
		skynet.error("在线奖励零点更新：",os.date("%X"))
		local allpeople = skynet.call("SIMPLEDB","lua","HVALS","onlinepeople")
		for i=1,#allpeople do
			local tab=json.decode(allpeople[i])
			pcall(function (player)
				skynet.call(player,"lua","zeroupdateonlinetime")
			end,math.ceil(tab.playeragent))
		end
		oneday(getupdatetime( ))
	end)
end



function update( second)
	skynet.timeout(second*60*100, function()--(time2-time1)*100
		skynet.error("排行榜更新啦时间是：",os.date("%X"))
		skynet.call("RANKINGLIST","lua","zerotime")
		update( second)
	end)
end
skynet.start(function (  )
	---------------------计算定时器时间
	-----------------------------------
	skynet.fork(update,10)

	skynet.fork(oneday,getupdatetime( ))
	-- skynet.timeout(1000, function()--(time2-time1)*100
	-- 	print("在线奖励重置")
	-- end)
	-----------------------------------
	skynet.dispatch("lua",function ( session,source,cmd,... )
		local f = assert(CMD[cmd])
		skynet.ret(skynet.pack(f(...)))
	end)
end)