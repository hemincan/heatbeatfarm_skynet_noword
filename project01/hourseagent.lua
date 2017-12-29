local skynet = require "skynet"
local fruit = require "fruit"
local CMD={}
local player = {}
----player[uniid]={agent,money,connecting,frequentreq={lasttime=0,clickcount=0}}

local MAXPLAYER = 20--最大人数,若想修改还要修改hourseserver的最大人数
local lastresult
local MAXCOUNT = 5--最大连任次数
local leavelist = {}--待离开游戏的玩家
local leavedearler --待,不当庄家的id
local status = {FREE=1,BUSY=2,OPEN=3}--三个状态无论那个都可以上庄家队列,free不可压,庄家可自由选择当不当庄家
--busy庄家不能动,庄家可压注,open状态,不可压不可下庄家,游戏开奖中
local gamestatus --游戏状态,如果是正在进行中,不可更换庄家,如果是休息状态,可以这段时间内更换,庄家选择下庄,也
--要等到一轮压注结束
------------
local clearthread --控制玩家游戏退出游戏的线程,游戏进行中不可退出,游戏准备中此线程运行
-- local disconthread={}--每个掉线用户启动一个线程
local reconnecttime = 10--掉线超时时间,秒
local hoursebeenkill = false
local ERRORCODE = require "errorcode"

local hourseserve = ...
-----------------------------------------
local preparetime = 10
local yazhutime = 15
local opentime =7
local showtime = 4--包含在preparetime中
--调试用
-- local preparetime = 4
-- local yazhutime = 5
-- local opentime =7
-- local showtime = 4--包含在preparetime中
-----------------------------------
--频繁操作解决
function frequentClick( uuid )
	player[uuid].frequentreq.clickcount=player[uuid].frequentreq.clickcount+1
	if player[uuid].frequentreq.clickcount>7 then
		local time = os.time()
		if time-player[uuid].frequentreq.lasttime>1 then
			player[uuid].frequentreq.lasttime=time
			player[uuid].frequentreq.clickcount=0
			return false
		else
			--print("对不起,你属于频繁点击")
			player[uuid].frequentreq.lasttime=time
			return true
		end
	end
	return false
end
function frequentTest( uniid )
	local ok,isfrq=pcall(frequentClick,uniid)
	if ok and isfrq then 
		tellerror( uniid, ERRORCODE.frquentclick)
		return true
	end
end
------------密集更新解决-----------
local frequentclick = 
{   frequentthreadran = false,
	lasttime = os.time(),
	count = 0,
	-- message={},
	realsend=0,
	oldsend=0,
}
function tellgameStatus(  )--应对密集的游戏更新
	frequentclick.oldsend=frequentclick.oldsend+1--数据测试
	-- frequentclick.message=x
	if os.time()==frequentclick.lasttime then
		 -- print("密集点击")
		--密集点击
		frequentclick.count=0--重置线程中的count,密码点击停下之后便可更新
		if not frequentclick.frequentthreadran then--没创建过这个线程
			frequentclick.frequentthreadran = true
			skynet.fork(function (  )
				while true do
					skynet.sleep(10)
					--print("thread run")
					frequentclick.count=frequentclick.count+1
					if frequentclick.count < 0 then
						break
					end
					if frequentclick.count>=4 then
						--发送消息
						tellgameStatus_Real(  )
						frequentclick.frequentthreadran=false
						break
					end
				end
			end)
		end
	else
		frequentclick.count=-1--线程可以停了,给一个负数
		frequentclick.lasttime=os.time()
		--发送消息
		tellgameStatus_Real(  )
	end
end

function tellgameStatus_Real(  )--把游戏状态告诉房间里所有的人
	frequentclick.realsend=frequentclick.realsend+1--数据测试
	local tmp = fruit:getGameStatus(  )
	tmp.action="gamestatus"
	for k,v in pairs(player) do
		local pstatus = fruit:getPlayerStatus( k )
		tmp.mystatus=pstatus
		if v.connecting then--不是待离开的人才通知
			tellagent(v.agent,tmp)
		end
	end
end
-- function tellgameStatustomyselfanddealer( uniid )
-- 	if not player[uniid] then
-- 		print("tellgameStatustomyselfanddealer,player nil")
-- 		return
-- 	end
-- 	if not fruit:isComputer() then --

-- 	end
-- end

function tellerror( uniid, code )
	--只给有错误的玩家
	local t = {action="error",code=code}
	if player[uniid].connecting then
		tellagent(player[uniid].agent,t)
	end
end
function tellstatus( t )--所有玩家共用同样的信息

	--遍历玩家table,分别给agent发送消息,t中已经存有状态信息
	for k,v in pairs(player) do
		if v.connecting then
			tellagent(v.agent,t)
		end
	end

end
function tellagent( agent,t )
	skynet.send(agent,"lua","tellagent",t)
end
local time_change = {}--计时时间
function time_change:init(  )
	self.preparetime=preparetime
	self.yazhutime=yazhutime
	self.opentime=opentime
end
time_change:init(  )
function time_change:time_counter(  )--时间计算器,为了在断线重连或者中途进入的时候给出一个精确度的时间
	if gamestatus==status.FREE then
		skynet.fork(function (  )
			while true do
				self.preparetime=self.preparetime-1
				skynet.sleep(100)
				if self.preparetime<=0 then
					self.preparetime=preparetime
					break
				end
			end
		end)
	elseif gamestatus==status.BUSY then
		skynet.fork(function (  )
			while true do
				self.yazhutime=self.yazhutime-1
				skynet.sleep(100)
				--print("self.yazhutime",self.yazhutime)
				if self.yazhutime<=0 then
					self.yazhutime=yazhutime
					break
				end
			end
		end)	
	elseif gamestatus==status.OPEN then
		skynet.fork(function (  )
			while true do
				self.opentime=self.opentime-1
				skynet.sleep(100)
				if self.opentime<=0 then
					self.opentime=opentime
					break
				end
			end
		end)	
	end
end

function CMD.getgamestatus( uniid )--主动请求游戏状态
	local tmp = fruit:getGameStatus(  )
	tmp.action="gamestatus"
	tmp.mystatus=fruit:getPlayerStatus( uniid )
	--只告诉uniid一个用户就可以了
	if player[uniid] then
		local agent = player[uniid].agent
		tellagent(agent,tmp)
		if gamestatus==status.FREE then
			tellagent(agent,{action="prepare",time=time_change.preparetime})
		elseif gamestatus==status.BUSY then
			--print("time_change.yazhutime",time_change.yazhutime)
			tellagent(agent,{action="busy",time=time_change.yazhutime})
		elseif gamestatus==status.OPEN then
			tellagent(agent,{action="result",time=time_change.opentime,result=lastresult,index=0})
		end
	end

end
function CMD.getonlinepeople( uniid )
	
	local agent = player[uniid].agent
	if agent then
		local tmp = {}
		tmp.action="onlinepeople"
		tmp.onlinepeople=fruit:getOnlinePeople(  )
		tellagent(agent,tmp)
	end
end
local messagespool = {maxsize=10,top=-1,pool={}}--消息池,用于存储最近10条数据
function messagespool:pushmessage( from,mess )
	self.top=(self.top+1)%self.maxsize
	self.pool[self.top]={from=from,mess=mess}
end
function messagespool:getmessagelist(  )
	local t = {}
	local bottom = (self.top+1)%self.maxsize
	local i = self.top
	while true do
		if i==bottom then
			table.insert(t,self.pool[i])
			return t
		end
		if self.pool[i] then
			table.insert(t,self.pool[i])
		else
			return t
		end
		i=(i-1)%self.maxsize
	end
end
function CMD.gethistorymessage( uniid )
	local agent = player[uniid].agent
	if agent then
		--{action="historymessage",list={{},{},{},{}}}
		local tmp ={}
		tmp.action ="historymessage"
		tmp.list = messagespool:getmessagelist()
		tellagent(agent,tmp)
	end
end
function CMD.sendmessage( uniid,mess )
	if not uniid then
		return
	end
	uniid=uniid.."  "..os.date("%H:%M:%S")
	tellstatus({action="messsage",newmsg=mess,from=uniid})
	messagespool:pushmessage(uniid,mess)
end
function CMD.gethistorylist( uniid )
	local agent = player[uniid].agent
	if agent then
		local tmp = {}
		if gamestatus==status.OPEN then--获得历史记录时如果是开奖,不能让它马上看到结果,先remove掉第一个再发
			tmp.historylist = fruit:getHistoryList(  )
			table.remove(tmp.historylist,1)
		else
			tmp.historylist = fruit:getHistoryList(  )
		end
		tmp.action = "history"
		tellagent(agent,tmp)
	end
end
local newplayer_notice = {}--玩家加入,leave消息队列
local newplayer_th
function CMD.newplayer( uniid ,agent ,headimgid,num )--
	if hoursebeenkill then
		return false
	end
	if player[uniid] then--有相同的人,,不继续向下运行,过渡阶段
		return false
	end
	if fruit:getPlayerCount(  )>=MAXPLAYER then--MAXPLAYER=5
		--print("人数已満")
		return false
	end
	--print("newplayer")

	--money=20000000
	skynet.error("用户加入房间",uniid)
	local x = skynet.call("mysqldb","lua","selectcashbyname",{username=uniid})
	--skynet.call("mysqldb","lua","intrank",{username=uniid})--init
	local money = x.cash
	--查询用户的金钱
	headimgid = headimgid or 1
	player[uniid]={agent=agent,money=money,connecting=true,frequentreq={lasttime=0,clickcount=0}}--通过redis查到它的agent地址,把它存起来
   
	local success,code = fruit:newPlayer( uniid, money,headimgid)--往游戏逻辑中加入玩家
	if not success then
		tellerror(uniid,code)
		--注释原因,fruit中newplayer不成功只有一种可能,就是同名的人,有同名的不能直接等于nil,因为这个同名的肯定还在游戏中
		--player[uniid]=nil--不成功,就不加入这个人,
		return false
	else
		--tellgameStatus(  )--newplayer 不再更新游戏状态

		table.insert(newplayer_notice,uniid)
		if not newplayer_th then
			newplayer_th=skynet.fork(function (  )
				local count = 0
				while true do
					skynet.sleep(40)
					count=count+1
					if count>5 then
						newplayer_th=nil
						break
					end
				end
				local tmp = newplayer_notice
				newplayer_notice={}
				local message
				-- if #tmp>2 then
				-- 	message = tmp[1]..","..tmp[2].."等加入了房间"
				-- else
					message = table.concat(tmp,",").."加入了房间"
				-- end
				--发送消息给客户端
				tellstatus({action="messsage",newmsg=message,from=""})
				
			end)
		end

		return true
	end
end
function CMD.leavehourse( uniid )
	skynet.error(uniid,"要离开房间了")
	if gamestatus==status.FREE then
		playerExit( uniid )
		return true
	else
		--print("玩家准备离开房间",uniid)`
		player[uniid].connecting=false--从此他必退
		table.insert(leavelist,uniid)--加入待退出玩家,
	end
	return true
end
--reconnect 和 disconnect没用
-- function CMD.reconnect( uniid )--重连后,服务器需要把状态推送给客户端口
-- 	player[uniid].connecting=true

-- end
-- function CMD.disconnect( uniid )
-- 	player[uniid].connecting=false
-- 	--做掉线的数据处理
-- 	disconthread[uniid]=skynet.fork(function (  )
-- 		local count = 0
-- 		local myid = uniid
-- 		while true do
-- 			if not player[myid].connecting then 
-- 				skynet.sleep(100)
-- 				count=count+1
-- 				if count>reconnecttime then
-- 					CMD.leavehourse(myid)
-- 					disconthread[uniid]=nil
-- 					break
-- 				end
-- 			else
-- 				--期间重新连接,connecting变成true
-- 				disconthread[uniid]=nil
-- 				break
-- 			end
-- 		end
-- 	end)
-- end

function syncMoney(  )--游戏逻辑中的Money和player中的money,把当局输的钱保存至数据库
	
	for k,v in pairs(player) do
		-- v.money=fruit:getPlayerMoney( k )
		local currentwin = fruit:getPlayerCurrentWin( k )
		v.money=v.money+currentwin
		if currentwin~=0 then
			--需要很多时间去处理...所以加了线程
			skynet.fork(function (  )
				skynet.call("mysqldb","lua","updatecashbyname",{username=k,cash=currentwin})
				if currentwin>0 then--只算正数
					skynet.call("mysqldb","lua","updaterank",{username=k,cash=currentwin})
				end
			end)
		end
	end
end
local leave_notice = {}--,leave消息队列
local leave_th
function playerExit( uniid )--只有玩家被服务器认可的退出才可调用此方法
	--退出房间做后续的工作,将用户的钱保存进数据库
	--应该记录下进入房间时有多少钱,将这个钱和现在的钱相减,再去减数据库
	-- skynet.error("空?",uniid)
	-- skynet.error("player[uniid]",player[uniid])
	tellagent(player[uniid].agent,{action="leavehoursesuccess"})
	fruit:playerExit( uniid )
	player[uniid]=nil
	skynet.send(hourseserve,"lua","playerexit",skynet.self())
	tellgameStatus(  )
	table.insert(leave_notice,uniid)
	if not leave_th then
		leave_th=skynet.fork(function (  )
			local count = 0
			while true do
				skynet.sleep(40)
				count=count+1
				if count>5 then
					leave_th=nil
					break
				end
			end
			local tmp = leave_notice
			leave_notice={}
			local message
			-- if #tmp>2 then
			-- 	message = tmp[1]..","..tmp[2].."等离开了房间"
			-- else
				message = table.concat(tmp,",").."离开了房间"
			-- end
			--发送消息给客户端
			tellstatus({action="messsage",newmsg=message,from=""})
		end)
	end
end

function CMD.wantdealer( uniid )--排队上庄
	local success,code = fruit:wantDealer( uniid )--上庄是否成功
	if not success then
		tellerror(uniid,code)
	else
		--如果是准备状态,电脑做庄,队列不为空,换为玩家做庄
		if gamestatus==status.FREE and fruit:isComputer() and #fruit:getDearlerList()>0 then
			fruit:changeDearler(  )
		end
		tellgameStatus(  )
	end
end
function CMD.exitdearlerlist( uniid )--取消排队
	local success,code = fruit:exitDearlerList( uniid )
	if not success then
		tellerror(uniid,code)
	else
		tellgameStatus(  )
	end
end
function CMD.exitdealer( uniid )--庄家不想当庄家
	if fruit:getDealerUid( )~=uniid then
		print("you are not a dealer!")
	elseif gamestatus==status.FREE then
		fruit:exitDealer( uniid )
		tellgameStatus(  )
	else
		--uniid是庄家,而且游戏在进行中
		leavedearler=uniid
		--print("当前不可下庄家,在此局游戏结束后下庄")
		tellerror(uniid,ERRORCODE.notadealernexttime)

	end
end


function CMD.yaluobo( uniid,money )
	if gamestatus==status.BUSY then
		local success ,code= fruit:yaLouBo( uniid,money )
		if success then
			tellgameStatus() --实时更新游戏状态 
		else
			tellerror( uniid, code)
		end
	else
		--print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end



function CMD.yabaicai( uniid,money )
	if gamestatus==status.BUSY then
		local success ,code= fruit:yaBaiCai( uniid,money )
		if success then
			tellgameStatus()--实时更新游戏状态
		else
			tellerror( uniid, code)
		end
	else
		--print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end
function CMD.yawandou( uniid,money )
	if gamestatus==status.BUSY then
		local success ,code= fruit:yaWanDou( uniid,money )
		if success then
			tellgameStatus()--实时更新游戏状态
		else
			tellerror( uniid, code)
		end
	else
		--print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end
function CMD.yanangua( uniid,money )
	if gamestatus==status.BUSY then
		local success ,code= fruit:yaNanGua( uniid,money )
		if success then
			tellgameStatus()--实时更新游戏状态
		else
			tellerror( uniid, code)
		end
	else
		--print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end
function CMD.yagangzhe( uniid,money )
	if gamestatus==status.BUSY then
		local success ,code= fruit:yaGangZhe( uniid,money )
		if success then
			tellgameStatus()--实时更新游戏状态
		else
			tellerror( uniid, code)
		end
	else
		--print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end
function CMD.yamogu( uniid,money )
	if gamestatus==status.BUSY then
		local success ,code= fruit:yaMoGu( uniid,money )
		if success then
			tellgameStatus()--实时更新游戏状态
		else
			tellerror( uniid, code)
		end
	else
		--print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end
function CMD.yaguangchangsu( uniid,money )
	if gamestatus==status.BUSY then
		local success ,code= fruit:yaGuangChangSu( uniid,money )
		if success then
			tellgameStatus()--实时更新游戏状态
		else
			tellerror( uniid, code)
		end
	else
		--print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end
function CMD.yayidianhong( uniid,money )
	if gamestatus==status.BUSY then
		local success ,code= fruit:yaYiDianHong( uniid,money )
		if success then
			tellgameStatus()
		else
			tellerror( uniid, code)
		end
	else
		--print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end

function hourseexit(  )
	--print("hourse exit,hourse exit,hourse exit,")
	for k,v in pairs(player) do--如果还有人,是不正常的
		skynet.error("房间还有人,被退出了!@!!!!!!!!!!!!!!")
		playerExit(k)
	end
	skynet.error("此房间真实发送游戏状态数和以前的更新数",frequentclick.realsend,frequentclick.oldsend)
	skynet.exit()
end
function CMD.killhourse(  )--房间已经要退出了
	hoursebeenkill=true
end
function CMD.start(  )--游戏主逻辑控制
	fruit:newgame(  )
	skynet.fork(function (  )
		while true do
			

			
			--{action="prepare",time=""}
			gamestatus=status.FREE--闲家不可压注,庄家可随意更换状态
			--print("游戏准备开始")

			tellstatus({action="prepare",time=preparetime})
			--游戏结果的展示阶段
			--tellgameStatus()
			tellgameStatus_Real(  )--这里不使用tellgameStatus()因为希望能让客户端及时的收到状态以便show的时候能正确展示
			tellstatus({action="show"})
			time_change:time_counter(  )
			skynet.sleep(showtime * 100)
			local earnmost = fruit:getEarnMost(  )
			if earnmost.maxmoney<=0 then
				--tellstatus({action="systemmsg",newmsg="上局没人赢钱T_T".."",from=""})
			elseif not earnmost.isdealer then
				tellstatus({action="systemmsg",newmsg="恭喜"..earnmost.name.."羸下了"..earnmost.maxmoney..",下局给我全吐出来!",from=""})
			else
				tellstatus({action="systemmsg",newmsg="恭喜"..earnmost.name.."当庄羸下了"..earnmost.maxmoney..",快点给我下庄!",from=""})
			end

			skynet.sleep((preparetime - showtime)*100)--此状态保持


			--skynet.error("game begin","地主ID  "..fruit:getDealerUid(  ),"连任次数"..fruit:getReslectCount(  ))
			
			-----------------------
			----{action="busy",time=""}
			-----------------------
			--print("游戏已经开始")
			gamestatus=status.BUSY--庄家不可更换,闲家压注
			tellstatus({action="busy",time=yazhutime})

			time_change:time_counter(  )
			skynet.sleep(yazhutime*100)--此状态保持
			---------------------
			local result=fruit:open()--游戏开奖,返回一个结果table

			--{action="result",result="",index="",time=""}
			lastresult=result.result

			result.action="result"
			result.time=opentime
			

			
			gamestatus=status.OPEN--开奖状态
			tellstatus(result)

			time_change:time_counter(  )
			skynet.sleep(opentime*100)--
			fruit:settleAccounts( )--结算这一局的结果
			fruit:newgame(  )--清除数据,重新开始
			syncMoney(  )--变化存入数据库

			--任何一种情况出现都要换庄家,连任次数到,庄家钱不够
			if fruit:getReslectCount(  )>=MAXCOUNT or (fruit:isComputer() and #fruit:getDearlerList()>0) or fruit:getDealerMoney()<fruit:getMinMoneyDealermusthave() then
				if fruit:getDealer( ) then
					if fruit:getReslectCount(  )>=MAXCOUNT then--连任次数到
						tellerror(fruit:getDealerUid(  ),ERRORCODE.reselectexpired)
					elseif fruit:getDealerMoney()<fruit:getMinMoneyDealermusthave() then --钱已不够当庄家
						tellerror(fruit:getDealerUid(  ),ERRORCODE.nomoneytoreselect)
					end
				end
				while true do
					local success ,code, playerid= fruit:changeDearler(  )
					if not success then
						tellerror( playerid, code)
					else
						break
					end
				end
			end
			---------------------
			skynet.wakeup(clearthread)--唤醒co做游戏结束后的处理
		end
	end)
	clearthread=skynet.fork(function (  )
		while true do
			skynet.wait()--可以让玩家退出的时候唤醒它
			--skynet.error("clear home!")

			-------------FREE状态---------------

			if #leavelist~=0 then
				for k,v in pairs(leavelist) do
					playerExit( v )
				end
				leavelist={}
			end
			if  leavedearler then
				--print(leavedearler,"退出庄家")
				fruit:exitDealer( leavedearler )
				leavedearler=nil
			end
			if hoursebeenkill then--如果已经收到房间管理者的退出消息,将在游戏结束后退出
				hourseexit(  )
			end
			------------------------------------
			tellgameStatus(  )
		end
	end)

end

skynet.start(function (  )
	skynet.dispatch("lua",function ( session,source,cmd,... )
		local f = CMD[cmd]
		if f then 
			if cmd=="newplayer" or cmd =="leavehourse" then
				skynet.ret(skynet.pack(f(...)))		
			else
				if frequentTest( ... ) then--如果太频繁,所有的动作都可能会不见效果,时间不能太短
				
				else
					f(...)
				end
			end
		end
	end)
end)