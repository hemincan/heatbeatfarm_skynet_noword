local skynet = require "skynet"
local socket = require "socket"
local queue = require "skynet.queue"
local pack = require "pack"
local cjson = require "cjson"
local json = cjson.new()
local ERRORCODE = require "errorcode"
local utityhelp = require "utityhelp"
local md5 = require "md5"

local heartbeatsum=60
local heartbeatnum=60
local lock
local CMD = {}
local MSG = {}
local fd
local tosendmesg = {}
local playerstatus = {session=0,onlinetime=0,reconnect=0,breakline=0}--游戏在线时长在断线后需要写入MySQL
local user = {uaccount=nil}
local lockaction = {"onlineRewards","getrewardsstage2","getrewardsstage3","getrewardsstage4","zeroupdateonlinetime"}
------------------------------------------------谢武幸

local HOURSESERVER=...

function tobype(str )
	print(str,"+++++++++++")
	str=string.pack(">s2",str)
	local x = string.byte(str,2)
	for i=1,x+2 do
		io.write(string.byte(str,i).." ")
	end
	io.write("\n")--打印字节码
end

function MSG.send(msg )--消息发送
	--print(json.encode(msg),"json data------------------------")
	msg.session=playerstatus.session
	playerstatus.session=playerstatus.session+1
	local st=pack.encode(msg)
	--tobype(st)
	socket.write(fd,pack.encode(msg).."hello")
end

function setrewardsstage1(  )--在线奖励
	if user.stage1==0 then
		skynet.call("mysqldb","lua","UPDATESTAGE1",{uid=user.uid})
		user.stage1=1
	end--设置可以领取一等奖
end
function setrewardsstage2(  )--在线奖励
	if user.stage2==0 then
		skynet.call("mysqldb","lua","UPDATESTAGE2",{uid=user.uid})
		user.stage2=1
	end 
end
function setrewardsstage3(  )--在线奖励
	if user.stage3==0 then
		skynet.call("mysqldb","lua","UPDATESTAGE3",{uid=user.uid})
		user.stage3=1
	end 
end
function setrewardsstage4(  )--在线奖励
	if user.stage4==0 then
		skynet.call("mysqldb","lua","UPDATESTAGE4",{uid=user.uid})
		user.stage4=1
	end 
end

function setonlinetime( onlinetime )
	print(onlinetime,"时间时间时间时间时间时间时间时间时间时间时间时间时间")
	if onlinetime<1800 then
		--setrewardsstage1(  )
		skynet.error("在线小于30分钟",user.uaccount)
	elseif 1800<=onlinetime and onlinetime<3600 then--30
		setrewardsstage1(  )
	elseif 3600<=onlinetime and onlinetime<10800 then--1小时
		skynet.error("在线1小时",user.uaccount)
		setrewardsstage1(  )
		setrewardsstage2(  )
	elseif 10800<=onlinetime and onlinetime<18000 then--3小时
		skynet.error("在线3小时",user.uaccount)
		setrewardsstage1(  )
		setrewardsstage2(  )
		setrewardsstage3(  )
	else--5小时
		skynet.error("在线5小时",user.uaccount)
		setrewardsstage1(  )
		setrewardsstage2(  )
		setrewardsstage3(  )
		setrewardsstage4(  )
	end--设置在线时间对应可领奖励
	-- if onlinetime<60 then
	-- 	--setrewardsstage1(  )
	-- 	skynet.error("在线小于30分钟",user.uaccount)
	-- elseif 60<=onlinetime and onlinetime<120 then--30
	-- 	setrewardsstage1(  )
	-- 	skynet.error("在线1小时",user.uaccount)
	-- elseif 120<=onlinetime and onlinetime<180 then--1小时
	-- 	skynet.error("在线1小时",user.uaccount)
	-- 	setrewardsstage1(  )
	-- 	setrewardsstage2(  )
	-- elseif 180<=onlinetime and onlinetime<240 then--3小时
	-- 	skynet.error("在线3小时",user.uaccount)
	-- 	setrewardsstage1(  )
	-- 	setrewardsstage2(  )
	-- 	setrewardsstage3(  )
	-- else--5小时
	-- 	skynet.error("在线5小时",user.uaccount)
	-- 	setrewardsstage1(  )
	-- 	setrewardsstage2(  )
	-- 	setrewardsstage3(  )
	-- 	setrewardsstage4(  )
	-- end--设置在线时间对应可领奖励
end

function getonlinerewards( ... )
	-- body
end


local function updateonlinepeoplecache( uaccount,tab )--更新缓存
	skynet.call("SIMPLEDB","lua","hset","onlinepeople",uaccount,json.encode(tab))
end 

local function deleteonlinepeoplecache( uaccount )--删除缓存
	skynet.call("SIMPLEDB","lua","hdel","onlinepeople",uaccount)
end 

function CMD.editeusername( msg )--编辑昵称
	if not user.username then
		MSG.send({action="error",code=ERRORCODE.editeusername} )
		return
	end
	local tf,code=utityhelp.lawfulusername(msg.newusername)
	if tf==false then
		MSG.send({action="error",code=code})
		return
	end
	msg.newusername=utityhelp.DelstrFl(msg.newusername)
	if msg.newusername==user.username then
		MSG.send({action="responseediteusername"} )
		return
	end
	--print(msg.newusername,utityhelp.strlen(msg.newusername),"user.username,-----------",string.len(tostring(msg.newusername)))
	local ishaveuser = skynet.call("mysqldb","lua","SELECTNAME",{username=msg.newusername})
	if ishaveuser then--昵称已经被使用
		MSG.send({action="error",code=ERRORCODE.havethisusername})
		return
	end
	msg.username=user.username
	local judge=skynet.call("mysqldb","lua","UPDATENAME",msg)
	if judge==true then
		MSG.send({action="responseediteusername"} )
		user.username=msg.newusername
	else
		MSG.send({action="error",code=ERRORCODE.editeusername} )
	end
end

function CMD.editeportrait( msg )----更改头像，msg.portrait,msg.uaccount
	if msg.portrait==nil or msg.portrait=="" then
		MSG.send({action="error",code=ERRORCODE.portraitnil})
		return
	end 
	skynet.call("mysqldb","lua","INTIPOR",{uaccount=user.uaccount,portrait=msg.portrait})
	user.portrait=msg.portrait
	MSG.send({action="responseportrait"})
end

function CMD.editupassword( msg )--修改登陆密码
	if msg.upassword~=user.upassword then
		MSG.send({action="error",code=ERRORCODE.upassworderror})
		return
	end
	msg.uid=user.uid
	local judge=skynet.call("mysqldb","lua","UPDATEPW",msg)
	if judge then
		MSG.send({action="responseeditupassword"})
	else
		MSG.send({action="error",code=ERRORCODE.editupassword})
	end
end


function CMD.editbankpassword( msg )--更改银行密码uid,bpassword,newbpassword,6到9位
	local tf code=utityhelp.lawfulbankpassword(msg.newbpassword)	
	if tf==false then
		MSG.send({action="error",code=ERRORCODE.editeusername} )
		return
	end
	msg.newbpassword=utityhelp.DelstrFl(msg.newbpassword)
	if msg.bpassword==user.bpassword then
		msg.uid=user.uid
		local judge = skynet.call("mysqldb","lua","UPDATEBPW",msg)
		print("修改密码",judge)
		if judge then
			user.bpassword=msg.newbpassword
			MSG.send({action="responseeditbankpassword"})
		else
			MSG.send({action="error",code=ERRORCODE.editbankpassword})
		end
	else
		MSG.send({action="error",code=ERRORCODE.bankpassworderror})
	end
end

function CMD.bankmoney( msg )--银行信息
	msg.username=user.username
	local bankmoney = skynet.call("mysqldb","lua","SELECTMONEYBYNAME",msg)
	if bankmoney[1]~=nil then
		user.deposit=bankmoney[1].deposit
		MSG.send({action="responsebankmoney",cash=bankmoney[1].cash,deposit=bankmoney[1].deposit})
	else
		MSG.send({action="error",code=ERRORCODE.getmsgovertime})
	end
end


function CMD.depositbank( msg )--存款
	if msg.money==nil or msg.money=="" then
		MSG.send({action="error",code=ERRORCODE.moneyisnegative})
		return
	end
	msg.money=tonumber(msg.money)
	if msg.money<0 then
		MSG.send({action="error",code=ERRORCODE.moneyisnegative})
		return
	end
	local mycash = skynet.call("mysqldb","lua","SELECTCASHBYNAME",{username=user.username})
	if mycash.cash<msg.money then
		MSG.send({action="error",code=ERRORCODE.deposittoobig})
		return
	end
	local x = skynet.call("mysqldb","lua","SAVEDEPOSITBYNAME",{username=user.username,deposit=msg.money})
	if x then
		user.deposit=user.deposit+msg.money
	 	MSG.send({action="responsedepositbank"})
	end
end

function CMD.Withdrawbank(msg )--取款
	if msg.bpassword~=user.bpassword then
		MSG.send({action="error",code=ERRORCODE.passeorderror})
		return
	end
	if msg.money==nil or msg.money=="" then
		MSG.send({action="error",code=ERRORCODE.moneyisnegative})
		return
	end
	msg.money=tonumber(msg.money)
	local mybank =skynet.call("mysqldb","lua","SELECTDEPOSIT",{uaccount=user.uaccount})
	if msg.money<0 then
		MSG.send({action="error",code=ERRORCODE.moneyisnegative})
		return
	end
	if msg.money>mybank.deposit then
		MSG.send({action="error",code=ERRORCODE.Withdrawtoobig})
		return
	end
	local x = skynet.call("mysqldb","lua","TAKEDEPOSITBYNAME",{username=user.username,deposit=msg.money})
	if x then
		user.deposit=mybank.deposit-msg.money
		MSG.send({action="responseWithdrawbank"})
	end
end

function CMD.sendtoClient(act,msg )--发送消息给客户端
	msg.action=act 
	MSG.send(msg)
end

function CMD.Recharge( msg )--假充值，实际为赢钱
	local judge = skynet.call("mysqldb","lua","UPDATECASH",msg)
	MSG.send({action="responseRecharge"})
end

function CMD.onlineRewards(  )--查询在线奖励详情 msg.uid, msg.day  -----test
	local time2=utityhelp.timetotime(user.onlinetime,os.date("%d-%H-%M-%S",tonumber(os.time())))
	--skynet.call("mysqldb","lua","UPDATEOT",{uid=user.uid,onlineTime=time2+user.time1})
	local onlineTime=time2+user.time1
	setonlinetime(onlineTime)
	MSG.send({action="responseonlineRewards",onlineTime=onlineTime,status={stage1=user.stage1,stage2=user.stage2,stage3=user.stage3,stage4=user.stage4}})
end

function CMD.getrewardsstage1(  )--就领取奖励1
	if user.stage1==1 then
		skynet.call("mysqldb","lua","GETREWARD1",{username=user.username})
		user.stage1=2
		MSG.send({action="responsestage1",money=500})
		return
	end
	MSG.send({action="error",code=ERRORCODE.norewards})
end

function CMD.getrewardsstage2(  )--就领取奖励2
	if user.stage2==1 then
		skynet.call("mysqldb","lua","GETREWARD2",{username=user.username})
		user.stage2=2
		MSG.send({action="responsestage2",money=2000})
		return
	end 
	MSG.send({action="error",code=ERRORCODE.norewards}) 
end

function CMD.getrewardsstage3(  )--就领取奖励3
	if user.stage3==1 then
		skynet.call("mysqldb","lua","GETREWARD3",{username=user.username})
		user.stage3=2
		MSG.send({action="responsestage3",money=8000})
		return
	end 
	MSG.send({action="error",code=ERRORCODE.norewards})
end

function CMD.getrewardsstage4(  )--就领取奖励4
	if user.stage4==1 then
		skynet.call("mysqldb","lua","GETREWARD4",{username=user.username})
		user.stage4=2
		MSG.send({action="responsestage4",money=50000})
		return
	end 
	MSG.send({action="error",code=ERRORCODE.norewards})
end

function CMD.usermsg(_ )--mysql查询用户信息，金币...记入redis,返回 
	local usermsg=skynet.call("mysqldb","lua","select",{uaccount=user.uaccount})
	--usermsg=json.decode(usermsg)
	skynet.error("用户信息帐号密码============",usermsg.uaccount,usermsg.username,usermsg.portrait)
	if usermsg then
		MSG.send({action="responseusermsg",uaccount=usermsg.uaccount,cash=usermsg.cash,username=usermsg.username,ishavehourse=user.myhourseid,portrait=usermsg.portrait})
	else
		MSG.send({action="error",code=ERRORCODE.getusermsgfailed})
	end
end

function CMD.selectHourse(hourseid)--选择房间进入
	local judge=true--skynet.call("SIMPLEDB","lua","get",hourseid)
	if judge and  user.myhourseid~=nil then 
		local isse=skynet.call(HOURSESERVER,"lua","selectHourse",skynet.self(),hourseid,user.userid)
		if isse then
			user.myhourseid=hourseid
			MSG.send({action="responsehoursesuccess"})
			return
		end
		MSG.send({action="error",code=ERRORCODE.fastinnerhourse})
	else
		MSG.send({action="error",code=ERRORCODE.havehourse})
	end
end

function CMD.hoursehall(msg)--进入游戏大厅
	local tab = skynet.call("HOURSESERVER","lua","hoursehall",msg)
	tab.action="hoursehall"
	MSG.send(tab)
end

function CMD.createhourse(  )--创建房间
	--local hourseid=skynet.service("hourseagent")
	if user.myhourseid==nil then
		local hourseid=skynet.call(HOURSESERVER,"lua","createhourse",skynet.self(),user.username,user.portrait)
		if hourseid then
			user.myhourseid=hourseid
			skynet.error("用户进入房间，用户名",user.myhourseid,user.uaccount)
			MSG.send({action="responsehoursesuccess"})
			return
		end	
		MSG.send({action="error",code=ERRORCODE.createhourse})
	else
		--MSG.send({action="error",code=ERRORCODE.havehourse})
		MSG.send({action="responsehoursesuccess"})
	end
end

function CMD.fastinnerHourse( )--快速进入房间
	if user.myhourseid==nil then
		local t1 = os.time()
		local hourseid,ok=skynet.call(HOURSESERVER,"lua","fastinnerHourse",skynet.self(),user.username,user.portrait)
		if hourseid then
			user.myhourseid=hourseid
			skynet.error("用户进入房间，用户名"..os.time()-t1,hourseid,user.uaccount,ok)
			MSG.send({action="responsehoursesuccess"})
			return
		end
		skynet.error("用户进入房间，用户名"..os.time()-t1,hourseid,user.uaccount,ok)
		MSG.send({action="error",code=ERRORCODE.fastinnerhourse})
	else
		--MSG.send({action="error",code=ERRORCODE.havehourse})
		MSG.send({action="responsehoursesuccess"})
	end
end

function CMD.close( )--关闭链接，关闭链接前先请求房间看用户是否还在房间（直接关闭手机或者断线的情况）
	if user.myhourseid~=nil then
		CMD.leavehourse(fd)
	end
	--更新在线时长， msg.uid, msg.onlineTime
	local time2=utityhelp.timetotime(user.onlinetime,os.date("%d-%H-%M-%S",tonumber(os.time())))
	skynet.call("mysqldb","lua","SAVEONLINE",{uid=user.uid,uaccount=user.uaccount,username=user.username,onlineTime=time2+user.time1})
	setonlinetime(time2+user.time1)
	skynet.error("玩家下线时间，之前登录时长，在线时长，总时长",os.date("%d-%H-%M-%S",tonumber(os.time())),user.time1,time2,time2+user.time1)
	if user.handshake~=nil then
		deleteonlinepeoplecache(user.uaccount)
		user.handshake=nil
	end
	CMD.socketclose( fd )
	print("玩家agent退出---------",fd)
	skynet.exit()
end

function CMD.socketclose( oldfd )
	if playerstatus.breakline==0 then--断线的两种情况，一种读为false，一种一直在读状态
		print("socket关闭",oldfd)
		playerstatus.breakline=1
		socket.close(oldfd)	
	end
end

function CMD.reliefmoneyinit( )--救济金初始化
	user.stage5= skynet.call("mysqldb","lua","SELECTSTAGE5",{uaccount=user.uaccount})
end


function CMD.getreliefmoney( )
	if user.stage5==1 then
		skynet.call("mysqldb","lua","GETALMS",{uaccount=user.uaccount})
		user.stage5=2
		MSG.send({action="responsegetreliefmoney",money=20000})
		return
	elseif user.stage5==2 then
		MSG.send({action="error",code=ERRORCODE.havereliefmoney})
		return
	else
		MSG.send({action="error",code=ERRORCODE.reliefmoney})
	end 
end

function CMD.reliefmoney(  )--查询是否符合救济金,msg.uaccount,设置是否救济金状态
	if user.stage5==2 then
		MSG.send({action="responsereliefmoney",status=2})
		return
	end
	if user.deposit<5000 and user.stage5~=2 then
		local tag=skynet.call("mysqldb","lua","SELECTALMS",{uaccount=user.uaccount})
		if tag==1 then
			MSG.send({action="responsereliefmoney",status=1})
			user.stage5=1
		else
			MSG.send({action="responsereliefmoney",status=0})
			user.stage5=0
		end
	else
		MSG.send({action="responsereliefmoney",status=0})
		user.stage5=0
	end
end


function CMD.shoppingmall(  )--商品类表
	MSG.send({action="responsemall",item1="item1",item2="item2",item3="item3",item4="item4"})
end

function CMD.submitorder( msg )--提交订单处理
	if msg.item~=nil and msg~="" then
		user.item=msg.item
	end
	MSG.send({action="responseorder",itemcode="22222"})
end

function getgoodprice(  )
	if user.item=="item1" then
		return 2
	end
	if user.item=="item2" then
		return 4
	end
	if user.item=="item3" then
		return 39.8
	end
	if user.item=="item4" then
		return 388
	end
	return false
end

function CMD.paymoney(  )--购买
	local price=getgoodprice(  )
	if price then
		skynet.call("mysqldb","lua","BUY",{uaccount=user.uaccount,price=price})--充值成功,传入msg.price， msg.uaccount
		----保存充值信息, 传入msg.uid, msg.uaccount, msg.username, msg.price, msg.notifytime, msg.state 
		skynet.call("mysqldb","lua","SAVEBUY",{uid=user.uid,uaccount=user.uaccount,username=user.username,price=price})
		user.item=nil
		MSG.send({action="responsepay"})
	else
		MSG.send({action="error",code=ERRORCODE.ordererror})
	end
end

function checkclose(cmd,num)
	lock(function (  )
		if cmd=="reconnect" then
			if num==0 then
				playerstatus.reconnect=1
			end
		else
			if num==0 then
				playerstatus.reconnect=2
			end
		end
	end)
	return playerstatus.reconnect
end

function CMD.reconnect(newfd,msg)--重连
	if checkclose("reconnect",playerstatus.reconnect)~=1 then
		MSG.send({action="error",code=ERRORCODE.overtime})
		CMD.socketclose(newfd)
		return
	end
	local hand = skynet.call("SIMPLEDB","lua","hget","onlinepeople",msg.uaccount)
	if hand then
		fd=newfd
		playerstatus.reconnect=true
		print("重连成功")
		--CMD.sendtoClient( fd,"reconnect",msg )
		fd=newfd
		if msg.visitor==1 then
			skynet.error("visitorcommom  reconnect")
			MSG.send({action="responsevisitor",handshake=user.handshake,uaccount=msg.uaccount,upassword=msg.upassword})
		else
			MSG.send({action="responselogin",handshake=user.handshake})
		end
		MSG.dispatch()
	end
	--usermsg( fd,msg )
end

function MSG.dispatch()--心跳检测，消息分发
	socket.start(fd)
	local sum = heartbeatsum
	skynet.fork(function (  )
			playerstatus.reconnect=0
			local currenfd=fd
			print("心跳检测最新fd",currenfd)
			playerstatus.breakline=0
			while true do
				sum=sum-1
				skynet.sleep(heartbeatnum)
				if currenfd~=fd then
					print("该玩家重连，旧心跳检测退出",currenfd)
					CMD.socketclose( currenfd )
					break
				end
				if sum<0 then
					if checkclose("close",playerstatus.reconnect)==2 then
						CMD.close( currenfd )
					else
						print("该玩家重连，旧心跳检测退出",currenfd)
						CMD.socketclose( currenfd )
					end
					break
				end
			end
	end)

	while true do
		local message = socket.readline(fd,"hello")	
		if message==false then
			print("message==false")
			CMD.socketclose( fd )
			break
		end
		--print(message,"原始编码")
		-- temp=string.pack(">s2",message)
		-- local x = string.byte(temp,2);
		-- for i=1,x do
		-- 	io.write(string.byte(temp,i).." ")
		-- end
		--skynet.error("信息---",message)
		local tf,str=pcall(pack.decode,message)
		print(str.action,"动作")
		if tf then
			if str and str.action~="heart" then
				print("str.action",str.action,str.action)
				local f = CMD[str.action]
				if f then
					f(str)
				end
			end
			sum=heartbeatsum
		end
	end
end

function CMD.initrewards(  )--在线奖励初始化
	local tab=skynet.call("mysqldb","lua","SELECTSTAGE",{uid=user.uid,uaccount=user.uaccount,username=user.username})
	print()
	user.time1=tab.onlineTime
	user.stage1=tab.stage1
	user.stage2=tab.stage2
	user.stage3=tab.stage3
	user.stage4=tab.stage4
	--MSG.send({action="",stage1=user.stage1,stage2=user.stage2,stage3=user.stage3,stage4=user.stage4,onlinetime=user.onlinetime})
end

function CMD.zeroupdateonlinetime( msg )--零点更新，系统调用
	local time=utityhelp.yesterdayonlinetime(user.onlinetime,os.date("%d-%H-%M-%S",tonumber(os.time())))
	skynet.error("昨日用户在线时间",time,os.date("%d-%H-%M-%S",tonumber(os.time())),user.uaccount)
	skynet.call("mysqldb","lua","SAVEYESTERDAY",{uid=user.uid,onlineTime=time})--msg.uid, msg.uaccount, msg.username,msg.onlineTime
	user.onlinetime=os.date("%d-%H-%M-%S",tonumber(os.time()))
	CMD.initrewards( )	
	CMD.reliefmoneyinit( )--救济金初始化
	--MSG.send({action="error",code=ERRORCODE.getusermsgfailed})
end

function playerinit( fdfd,msg )--所有数据初始化
	fd=fdfd
	local tab=skynet.call("mysqldb","lua","select",msg)
	user.bpassword=tab.bpassword
	user.username=tab.username-- uuid.new()
	user.handshake=tab.uaccount.."@"..os.date("%X")
	user.uaccount=tab.uaccount
	user.uid=tab.uid
	user.onlinetime=os.date("%d-%H-%M-%S",tonumber(os.time()))
	user.deposit=tab.deposit
	user.portrait=tab.portrait

	-- tab.onlinetime=user.onlinetime
	-- tab.handshake=user.handshake
	-- tab.playeragent=skynet.self()


	CMD.initrewards(  )--在线奖励初始化
	CMD.reliefmoneyinit( )--救济金初始化

	updateonlinepeoplecache(tab.uaccount,{uaccount=user.uaccount,upassword=tab.upassword,onlinetime=user.onlinetime,handshake=user.handshake,playeragent=skynet.self()})
end

function CMD.logincommon( fdfd ,msg)--登陆初始化
	playerinit( fdfd,msg )
	MSG.send({action="responselogin",handshake=user.handshake})
	MSG.dispatch()
end

function CMD.registercommon( fdfd ,msg)--登陆初始化
	print(msg.username,"------------------------",msg.uaccount)
	playerinit( fdfd,msg )
	print("注册信息",msg.uaccount) 
	MSG.send({action="responseregister",handshake=user.handshake})
	MSG.dispatch()
end

function CMD.visitorcommom(fdfd,msg )
	playerinit( fdfd,msg )
	MSG.send({action="responsevisitor",handshake=user.handshake,uaccount=msg.uaccount,upassword=msg.upassword})
	MSG.dispatch()
end

function CMD.logout(  )--退出游戏
	--清除uuid缓存，关闭socket,数据写入MySQL，清除redis数据
	CMD.close( fd )
end

------------------------------------------------谢武幸

-----------------------------------------------------何敏灿
function CMD.getyesdaylist(  )--获得日赢金币排行 
	local list = skynet.call("RANKINGLIST","lua","getyesdaylist")
	MSG.send(list)
end

function CMD.getyesdayalllist(  )--获得昨日总排行
	local list = skynet.call("RANKINGLIST","lua","getyesdayalllist")
	MSG.send(list)
end


function CMD.getonlinepeople( )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","getonlinepeople",user.username)
end

function CMD.gethistorylist(  )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","gethistorylist",user.username)
end

function CMD.tellagent( t )--由房间调用
	MSG.send(t)
end

function CMD.leavehourse( )--离开房间
	if  user.myhourseid then
		skynet.error("用户离开房间，用户名",user.myhourseid,user.uaccount)
		skynet.call(HOURSESERVER,"lua","leavehourse",user.username, user.myhourseid)
		user.myhourseid=nil
	end
end

function CMD.getgamestatus(  )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","getgamestatus",user.username)
end
function CMD.wantdealer(  )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","wantdealer",user.username)
end
function CMD.exitdearlerlist(  )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","exitdearlerlist",user.username)
end
function CMD.exitdealer(  )--下庄，不当庄家
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	skynet.send(hagent,"lua","exitdealer",user.username)
end
function CMD.yaluobo( msg )
	hagent=user.myhourseid
	print(hagent, msg.money)
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end

	skynet.send(hagent,"lua","yaluobo",user.username,tonumber(msg.money))
end
function CMD.yabaicai( msg )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yabaicai",user.username,tonumber(msg.money))
end
function CMD.yawandou( msg )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yawandou",user.username,tonumber(msg.money))
end
function CMD.yanangua( msg )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yanangua",user.username,tonumber(msg.money))
end
function CMD.yagangzhe( msg )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yagangzhe",user.username,tonumber(msg.money))
end
function CMD.yamogu( msg )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yamogu",user.username,tonumber(msg.money))
end
function CMD.yaguangchangsu( msg )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yaguangchangsu",user.username,tonumber(msg.money))
end
function CMD.yayidianhong( msg )
	hagent=user.myhourseid
	if not hagent then 
		return
	end
	if not msg.money then
		return
	end
	skynet.send(hagent,"lua","yayidianhong",user.username,tonumber(msg.money))
end
-----------------------------------------------------何敏灿
skynet.start(function( )
	lock=queue()
	skynet.dispatch("lua",function (session,source,cmd,...)
		local f=assert(CMD[cmd])
		if cmd=="tellagent" or cmd=="registercommon" or cmd=="logincommon" or cmd=="visitorcommom" then--断线的两种情况，一种读为false，一种一直在读状态
			f(...)
		else
			skynet.ret(skynet.pack(f(...)))
		end
	end)
end)