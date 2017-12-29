local skynet = require "skynet"
local socket = require "socket"
local netpack = require "netpack"
local queue = require "skynet.queue"
local uuid=require "crearuuid"

local cjson = require "cjson"
local json = cjson.new()

local heartbeatsum=60
local lock
local CMD = {}
local MSG = {}
local playerstatus = {session=0,onlinetime=0,reconnect=false}--游戏在线时长在断线后需要写入MySQL
local myfd
------------------------------------------------谢武幸
function MSG.send(fd,msg )--消息发送
	socket.write(fd,msg.."\n")
end

function playeronlinetime( ... )

end

function CMD.sendtoClient( fd,act,msg )--发送消息给客户端
	msg.action=act 
	msg.session=playerstatus.session
	playerstatus.session=playerstatus.session+1
	MSG.send(fd,json.encode(msg))
end

function usermsg( fd,msg )--mysql查询用户信息，金币...记入redis,返回 
	-- body
	--print(fd,msg)
	--local usermsg=skynet.call("mysqldb","lua","select",msg)
	--skynet.call("SIMPLEDB","lua","hset",usermsg)--将常用数据存入redis
	local uuid=uuid.new()
	skynet.call("SIMPLEDB","lua","hset",uuid,fd)
	socket.write(fd,"你的fd是.."..fd.." 你的握手码是 "..uuid.."\n")
end

function CMD.selecthourse( _ ,hourseid)--选择房间进入
	local judge=true--skynet.call("SIMPLEDB","lua","get",hourseid)
	if judge then
		skynet.call("HOURSESERVER","lua","selecthourse",uuid,hourseid,skynet.self())
		playerstatus.myhourseid=hourseid
	else

	end
end
function CMD.createhourse(  )--创建房间
	--local hourseid=skynet.service("hourseagent")
	local hourseid=skynet.call("HOURSESERVER","lua","createhourse",uuid,skynet.self())
	playerstatus.myhourseid=hourseid
end

function CMD.fastinnerhourse( )--快速进入房间
	local hourseid=skynet.call("HOURSESERVER","lua","fastinnerhourse",uuid,skynet.self())
	playerstatus.myhourseid=hourseid
end

function hall( fd )--进入游戏大厅
	--socket.write(fd,"66666666666\n")
	local tab = skynet.call("HOURSESERVER","lua","hoursehall",fd)
	CMD.sendtoClient( fd,"hall",tab )
end

function CMD.promitsendreward( msg )--允许发放奖励
	--判断奖励等级
	-- local onlinetime=skynet.call("SIMPLEDB","lua","get","onlinetime")
	-- local starttime=skynet.call("SIMPLEDB","lua","get","starttime")
end

function CMD.sendreward( msg )--发放奖励
	
end

function CMD.close(  )--关闭链接，关闭链接前先请求房间看用户是否还在房间（直接关闭手机或者断线的情况）
	if playerstatus.myhourseid~=nil then
		CMD.leavehourse(uuid)
	end
	if playerstatus.handshake~=nil then
		playerstatus.handshake=nil
		skynet.call("SIMPLEDB","lua","hdel",playerstatus.handshake)
	end
	print("玩家agent退出---------",uuid)
	skynet.exit()
end

function CMD.socketclose( fd )
	socket.close(fd)
end

function CMD.reconnect( fd ,msg)--重连
	playerstatus.reconnect=true
	print("重连成功")
	--CMD.sendtoClient( fd,"reconnect",msg )
	
	myfd=fd


	CMD.sendtoClient( fd,"reconnect",{myhourseid=playerstatus.myhourseid} )
	MSG.dispatch(fd)
	--usermsg( fd,msg )
end

function MSG.dispatch(fd)--心跳检测，消息分发
	socket.start(fd)
	myfd=fd
	local sum = heartbeatsum
	skynet.fork(function (  )
		lock(function (  )
			print("开启心跳",fd)
			while true do
				sum=sum-1
				skynet.sleep(20)
				if playerstatus.reconnect==true then
					print("该玩家重连，旧心跳检测退出",fd)
					playerstatus.reconnect=false
					break
				end
				if sum<0 then
					CMD.close( fd )
					break
				end
			end
		end)
	end)

	while true do
		local message = socket.readline(fd)	
		if message==false then
			socket.close(fd)
			break
		end
		local str=json.decode(message)
		if str.action~="heart" then
			print("str.action",str.action,str.action)
			local f = CMD[str.action]
			assert(f)
			if f then
				f(fd)
			end
		end
		sum=heartbeatsum
	end
end

function CMD.common( fd ,msg)--登陆初始化
	--skynet.call("SIMPLEDB","lua","set",fd,fd)
	usermsg(fd,msg)
	hall(fd)
	MSG.dispatch(fd)
end

function CMD.logout( fd )--退出游戏
	--清除uuid缓存，关闭socket,数据写入MySQL，清除redis数据

	CMD.close( fd )
	skynet.exit()
end

function CMD.ranking( fd,msg )--排行榜
	skynet.call("mysqldb","lua","",msg)
end

function CMD.moneymsg ( fd,msg )--财富信息
	skynet.call("mysqldb","lua","",msg)
end

function CMD.bankaddmoney( fd,msg )--存入银行
	skynet.call("mysqldb","lua","",msg)
end

function CMD.bankdeletemoney( fd,msg )--从银行取出金币
	skynet.call("mysqldb","lua","",msg)
end

------------------------------------------------谢武幸

-----------------------------------------------------
function CMD.tellagent( t )--由房间调用
	local m = json.encode(t)
	CMD.send(myfd,m)
end

function CMD.leavehourse( )--离开房间
	skynet.call("HOURSESERVER","lua","leavehourse",uuid, playerstatus.myhourseid)
	playerstatus.myhourseid=nil
end
function CMD.getgamestatus(  )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","getgamestatus",uuid)
end
function CMD.wantdealer(  )

	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","wantdealer",uuid)
end
function CMD.exitdearlerlist(  )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","exitdearlerlist",uuid)
end
function CMD.exitdealer(  )--下庄，不当庄家
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","exitdealer",uuid)
end
function CMD.yaluobo( _,msg )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yaluobo",uuid,tonumber(msg.money))
end
function CMD.yabaicai( _,msg )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yabaicai",uuid,tonumber(msg.money))
end
function CMD.yawandou( _,msg )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yawandou",uuid,tonumber(msg.money))
end
function CMD.yanangua( _,msg )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yanangua",uuid,tonumber(msg.money))
end
function CMD.yagangzhe( _,msg )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yagangzhe",uuid,tonumber(msg.money))
end
function CMD.yamogu( _,msg )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yamogu",uuid,tonumber(msg.money))
end
function CMD.yaguangchangsu( _,msg )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yaguangchangsu",uuid,tonumber(msg.money))
end
function CMD.yayidianhong( _,msg )
	hagent=playerstatus.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yayidianhong",uuid,tonumber(msg.money))
end
-----------------------------------------------------
skynet.start(function(  )
	lock=queue()
	skynet.dispatch("lua",function (session,source,cmd,...)
		if cmd=="tellagent" then
			local f=assert(CMD[cmd])
			f(...)
		else
			local f=assert(CMD[cmd])
			skynet.ret(skynet.pack(f(...)))
		end
	end)
end)