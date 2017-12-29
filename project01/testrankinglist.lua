local skynet = require "skynet"

function printtable( t ,s)
	-- s=s..s
	-- for k,v in pairs(t) do
	-- 	print(s,k,v)
	-- 	if type(v)=="table" then
	-- 		printtable(v,s)
	-- 	end
	-- end

	for k,v in pairs(t) do
		if type(v)=="table" then
			print(k,v[1],v[2])
		end
	end
end
function sss(  )
	skynet.fork(function (  )
		while true do
			skynet.sleep(200)
			skynet.call(rankinglist,"lua","zerotime")
		end
	end)
	skynet.fork(function (  )
		while true do
			skynet.sleep(100)
			local x = skynet.call(rankinglist,"lua","getyesdayalllist")
			print("==============")
			printtable(x,"**")
		end
	end)
end
skynet.start(function (  )
	rankinglist = skynet.newservice("rankinglist")
	skynet.newservice("mysqldb")
	skynet.call(rankinglist,"lua","zerotime")
	local x = skynet.call(rankinglist,"lua","getyesdaylist")
	printtable(x,"##")
	local x = skynet.call(rankinglist,"lua","getyesdayalllist")
	printtable(x,"**")
	sss()
end) 