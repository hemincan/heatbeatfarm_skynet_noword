local skynet = require "skynet"
local queue = require "skynet.queue"
require "skynet.manager"	-- import skynet.register
local CMD = {}
local x = ...
local HOURSEPEOPLE = 6
local lock 
local hourses = {}--[hourseid]={zerocount=0,num=1}
local newhourseindex = {}
local hourselist = {head={tail=true}}--{head=nil,next}
function hourselist:push( t )
	t.next = self.head
	self.head = t
end

function CMD.playerexit( hourseid )--房间发来的退出通知
	lock(function ( )
		hourses[hourseid].num=hourses[hourseid].num-1
		if hourses[hourseid].num==0 then
			closehourse(hourses[hourseid])
		end
	end)
end

function CMD.selectHourse( playeragent,hourseid ,uuid,portrait)--用户进入房间
	local successs = false
	hourses[hourseid].lock(function ( )
		local time = os.time()
		local success = skynet.call(hourseid,"lua","newplayer",uuid,playeragent,portrait)
		if success then
			-- hourses[hourseid].num=hourses[hourseid].num+1
			successs= true
		end
		-- skynet.error("dfjsdfksdjf",time-os.time())
	end)
	return successs
end
function createhourse(  )
	local hourseid = skynet.newservice("hourseagent",skynet.self())
	skynet.send(hourseid,"lua","start")
	return hourseid
end

function CMD.createhourse(playeragent,uuid,portrait)--用户创建房间
	local hourseid = createhourse(  )
	skynet.error("撒地方啊地方完毕 ",hourseid)
	local success = skynet.call(hourseid,"lua","newplayer",uuid,playeragent,portrait)
	if success then
		hourses[hourseid]={num=1,id=hourseid,lock=queue()}
		hourselist:push(hourses[hourseid])
		return hourseid
	else
		skynet.error("创建成功,但加入失败")
		return
	end

end
function closehourse(hoursetable)--关闭房间
	--skynet.send(hourseid,"lua","killhourse")
	local destoryid = hoursetable.id
	hourses[destoryid]=nil
	local t = hoursetable.next
	if t.tail then
		hoursetable.tail=true
		hoursetable.next=nil
		hoursetable.num=nil
		hoursetable.id=nil
	else
		hoursetable.next=t.next
		hoursetable.num=t.num
		hoursetable.id=t.id
		hourses[t.id]=hoursetable
	end
	skynet.send(destoryid,"lua","killhourse")
end

function CMD.leavehourse( uuid,hourseid )--退出房间
	skynet.call(hourseid,"lua","leavehourse",uuid)
end
local currentnode=hourselist.head

function findhourse( playeragent,uuid,portrait )
	local hourseid=nil 
		local count = 0
		if currentnode.tail or not hourses[currentnode.id] then
			skynet.error("SDfffffffffffffffffffffffffff")
			currentnode=hourselist.head
		end
		--skynet.error("currentnode",currentnode)
		while not currentnode.tail do
			-- skynet.error("currentnode",currentnode)
			count=count+1
			currentnode=currentnode.next
			if currentnode.tail or not currentnode then
				hourseid = CMD.createhourse(playeragent,uuid,portrait)
				currentnode=hourselist.head
				-- for i=1,3 do
				-- 	local newhid = createhourse( )
				-- 	hourses[newhid]={num=0,id=newhid}
				-- 	hourselist:push(hourses[newhid])
				-- end
				return
			end

			currentnode.lock(function ( )
				if currentnode.num<HOURSEPEOPLE then
					hourses[currentnode.id].num=hourses[currentnode.id].num+1
					hourseid=currentnode.id
					return
				end
			end)

		end 
		-- for k,v in pairs(hourses) do
		-- 	if v.num<HOURSEPEOPLE then
		-- 		count=count+1
		-- 		hourses[k].num=hourses[k].num+1
		-- 		hourseid=k
		-- 	end
		-- end
		-- skynet.error("同学问我分斯蒂芬三点过",count,hourseid)

	return hourseid
end
function CMD.fastinnerHourse( playeragent,uuid,portrait)--快速进入房间,把房间号返回给用户拿着
	local time = os.time()
	local hourseid = findhourse( playeragent,uuid,portrait )
	skynet.error("findhourse",time-os.time())

	--skynet.error("找到阿凡达就啊灵个的分",hourseid)
	local time = os.time()
	if hourseid then
		-- skynet.error("找到",hourseid)
		local success = CMD.selectHourse( playeragent,hourseid ,uuid,portrait)
		if success then
			skynet.error("selectHourse",time-os.time())
			return hourseid
		else

			return CMD.createhourse(playeragent,uuid,portrait)
		end
	else
		return CMD.createhourse(playeragent,uuid,portrait)
	end
end

skynet.start(function (  )
	lock=queue()
	skynet.fork(function (  )
		while true do
			local x = 0	
			skynet.error("又怒我有体会`````````````````")
			for k,v in pairs(hourses) do
				x=x+1
				skynet.error("又怒我有体会",v.num)
			end
			skynet.sleep(1000)
			if x~=0 then
				-- skynet.error("又怒我有体会",x)
			end
		end
	end)

	skynet.dispatch("lua",function ( session,source,cmd,... )
		skynet.error(skynet.mqlen(),"消息队列长度")
		local f = assert(CMD[cmd])
		if cmd~="playerexit" then
			skynet.ret(skynet.pack(f(...)))
		else
			f(...)
		end
	end)
	skynet.register ("HOURSESERVER"..x)
end)