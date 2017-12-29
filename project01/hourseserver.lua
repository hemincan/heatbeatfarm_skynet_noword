local skynet = require "skynet"
local queue = require "skynet.queue"
require "skynet.manager"	-- import skynet.register
local CMD = {}
local x = ...
local HOURSEPEOPLE = 6
local lock 
local hourses = {}--[hourseid]={zerocount=0,num=1}
local leavenum = {} --[hourseid]=num
local hourseindex = {} --[1]={hourseid=,num=,book=}
local hourseindex_tmp = {}
function CMD.playerexit( hourseid )--房间发来的退出通知
	leavenum[hourseid]=leavenum[hourseid]+1
end

function CMD.selectHourse( playeragent,hourseid ,uuid,portrait)--用户进入房间
	local success = skynet.call(hourseid,"lua","newplayer",uuid,playeragent,portrait)
	if success then
		hourses[hourseid].num=hourses[hourseid].num+1
		return true
	end
	return false
end

function CMD.createhourse(playeragent,uuid,portrait)--用户创建房间
	local hourseid = skynet.newservice("hourseagent",skynet.self())
	local success = skynet.call(hourseid,"lua","newplayer",uuid,playeragent,portrait)
	if success then
		hourses[hourseid]={zerocount=0,num=1}
		leavenum[hourseid]=0
		local index = {hourseid=hourseid,num=1,book=0}
		table.insert(hourseindex_tmp,index)
		return hourseid
	else
		--理论上说不会失败
		skynet.error("创建成功,但加入失败")
		return
	end

end

function closehourse( fd,hoursefd )--关闭房间
	skynet.send(hoursefd,"lua","closehourse")
end

function CMD.leavehourse( uuid,hourseid )--退出房间
	skynet.call(hourseid,"lua","leavehourse",uuid)
end

function findhourse(  )
	for i,v in ipairs(hourseindex) do
		if v.book>=0  then
			v.book=v.book-1
			return v.hourseid
		end
		if i>#hourseindex then
			return false
		end
	end
end
function CMD.fastinnerHourse( playeragent,uuid,portrait)--快速进入房间,把房间号返回给用户拿着
	local hourseid = findhourse(  )
	if hourseid then
		local success = CMD.selectHourse( playeragent,hourseid ,uuid,portrait)
		if success then
			return hourseid
		else
			return CMD.createhourse(playeragent,uuid,portrait)
		end
	else
		return CMD.createhourse(playeragent,uuid,portrait)
	end
end
function hoursethread(  )
	skynet.fork(function (  )
		skynet.sleep(500)
		local newhourseindex = {}
		for k,v in pairs(hourseindex) do
			local hourseid = v.hourseid
			hourses[hourseid].num=hourses[hourseid].num-leavenum[hourseid]
			local x = {hourseid=hourseid,num=hourses[hourseid].num,book=HOURSEPEOPLE-hourses[hourseid].num}
			table.insert(newhourseindex,x)
			leavenum[k]=0
		end
		hourseindex=newhourseindex
		hourseindex=nil
	end)
end


skynet.start(function (  )
	lock=queue()
	hoursethread()
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