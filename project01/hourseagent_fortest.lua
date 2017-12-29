local skynet = require "skynet"
local fruit = require "fruit"
local CMD={}
local player = {}
----player[uniid]={agent,money,connecting}


local lastresult
local MAXCOUNT = 2--最大连任次数
local leavelist = {}--待离开游戏的玩家
local leavedearler --待,不当庄家的id
local status = {FREE=1,BUSY=2,OPEN=3}--三个状态无论那个都可以上庄家队列,free不可压,庄家可自由选择当不当庄家
--busy庄家不能动,庄家可压注,open状态,不可压不可下庄家,游戏开奖中
local gamestatus --游戏状态,如果是正在进行中,不可更换庄家,如果是休息状态,可以这段时间内更换,庄家选择下庄,也
--要等到一轮压注结束
------------
local clearthread --控制玩家游戏退出游戏的线程,游戏进行中不可退出,游戏准备中此线程运行
local disconthread={}--每个掉线用户启动一个线程
local reconnecttime = 10--掉线超时时间,秒
local ERRORCODE = require "errorcode"

function tellgameStatus(  )--告诉房间里所有的人
	local tmp = fruit:getGameStatus(  )
	tmp.action="gamestatus"
	for k,v in pairs(player) do
		if k=="aaaaaaaa" then
		local pstatus = fruit:getPlayerStatus( k )
		--pstatus
	     --- money=money
	      --luobo=0
	      --baicai=0
	      --wandou=0
	      --nangua=0
	     -- gangzhe=0
	     -- mogu=0
	     -- guangchangsu=0
	     -- yidianhong=0
	     -- currentwin=0
	     -- win=0
		tmp.mystatus=pstatus
		--tellagent(agent,t)
		print("****************************************")
		print("****************************************")
		for k,v in pairs(tmp) do
			if type(v)=="table" then
				print(k)
				for i,j in pairs(v) do
					if k=="onlinepeople" then
						print("x       ",i,j,fruit:getPlayerMoney(j))
					else
						print("x       ",i,j)
					end
				end
			else
				print(k,v)
			end
		end
		tellagent("TESTSERVER",tmp)
		end
	end
	
end
function tellerror( uniid, code )
	if uniid=="aaaaaaaa" then
		local t = {action="error",code=code}
		tellagent("TESTSERVER",t)
	end
end
function tellstatus( t )--所有玩家共用同样的信息

	--遍历玩家table,分别给agent发送消息,t中已经存有状态信息
	tellagent("TESTSERVER",t)

end
function tellagent( agent,t )
	--拜托agent把消息传到客户端
	skynet.send(agent,"lua","tellagent",t)
end
function CMD.getgamestatus( uniid )--主动请求游戏状态
	local tmp = fruit:getGameStatus(  )
	tmp.action="gamestatus"
	tmp.mystatus=fruit:getPlayerStatus( uniid )
	--只告诉uniid一个用户就可以了
	if player[uniid] then
		local agent = player[uniid].agent
		tellagent("TESTSERVER",tmp)
	end

end

function CMD.newplayer( uniid, money )--
	print("newplayer")
	player[uniid]={agent="0000",money=money,connecting=true}--通过redis查到它的agent地址,把它存起来
	local success,code = fruit:newPlayer( uniid, money )--往游戏逻辑中加入玩家
	if not success then
		tellerror(uniid,code)
	else
		tellgameStatus(  )
	end
end
function CMD.leavehourse( uniid )
	if gamestatus==status.FREE then
		playerExit( uniid )
	else
		print("玩家准备离开房间",uniid)
		table.insert(leavelist,uniid)--加入待退出玩家,
	end
end
function CMD.reconnect( uniid )--重连后,服务器需要把状态推送给客户端口
	player[uniid].connecting=true

end
function CMD.disconnect( uniid )
	player[uniid].connecting=false
	--做掉线的数据处理
	disconthread[uniid]=skynet.fork(function (  )
		local count = 0
		local myid = uniid
		while true do
			if not player[myid].connecting then 
				skynet.sleep(100)
				count=count+1
				if count>reconnecttime then
					CMD.leavehourse(myid)
					disconthread[uniid]=nil
					break
				end
			else
				--期间重新连接,connecting变成true
				disconthread[uniid]=nil
				break
			end
		end
	end)
end
function playerExit( uniid )--只有玩家被服务器认可的退出才可调用此方法
	fruit:playerExit( uniid )
	--退出房间做后续的工作,将用户的钱保存进数据库


	player[uniid]=nil
	tellgameStatus(  )
end


function CMD.wantdealer( uniid )--排队上庄
	local success,code = fruit:wantDealer( uniid )--上庄是否成功
	if not success then
		tellerror(uniid,code)
	else
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
		print("当前不可下庄家,在此局游戏结束后下庄")
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
		print("压注失败,游戏稍后开始!")
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
		print("压注失败,游戏稍后开始!")
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
		print("压注失败,游戏稍后开始!")
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
		print("压注失败,游戏稍后开始!")
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
		print("压注失败,游戏稍后开始!")
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
		print("压注失败,游戏稍后开始!")
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
		print("压注失败,游戏稍后开始!")
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
		print("压注失败,游戏稍后开始!")
		tellerror( uniid, ERRORCODE.gameisprepare)
	end
end
function syncMoney(  )--游戏逻辑中的Money和player中的money
	for k,v in pairs(player) do
		v.money=fruit:getPlayerMoney( k )
	end
end

local preparetime = 5
local yazhutime = 10
local opentime =5
function CMD.start(  )--游戏主逻辑控制
	fruit:newgame(  )
	skynet.fork(function (  )
		while true do
			

			
			--{action="prepare"}
			gamestatus=status.FREE--闲家不可压注,庄家可随意更换状态
			print("游戏准备开始")
			tellstatus({action="prepare"})

			skynet.sleep(preparetime*100)--此状态保持10S
			skynet.error("game begin","地主ID  "..fruit:getDealerUid(  ),"连任次数"..fruit:getReslectCount(  ))
			
			-----------------------
			----{action="busy"}
			-----------------------
			print("游戏已经开始")
			gamestatus=status.BUSY--庄家不可更换,闲家压注
			tellstatus({action="busy"})
			skynet.sleep(yazhutime*100)--此状态保持10S
			---------------------
			local result=fruit:open()--游戏开奖,返回一个结果table

			--{action="result",result="",index=""}
			lastresult=result.result

			result.action="result"
			
			

			syncMoney(  )
			gamestatus=status.OPEN--开奖状态
			tellstatus(result)


			skynet.sleep(opentime*100)--此状态保持10S
			fruit:newgame(  )--清除数据,重新开始
			if fruit:getReslectCount(  )>=MAXCOUNT then
				fruit:changeDearler(  )
			elseif fruit:isComputer() and #fruit:getDearlerList()>0 then
				--如果是电脑做庄,队列不为空,换为玩家做庄
				fruit:changeDearler(  )
			end
			---------------------
			skynet.wakeup(clearthread)--唤醒co做游戏结束后的处理
		end
	end)
	clearthread=skynet.fork(function (  )
		while true do
			skynet.wait()--可以让玩家退出的时候唤醒它
			skynet.error("clear home!")

			-------------FREE状态---------------

			if #leavelist~=0 then
				for k,v in pairs(leavelist) do
					playerExit( v )
				end
				leavelist={}
			end
			if  leavedearler then
				print(leavedearler,"退出庄家")
				fruit:exitDealer( leavedearler )
				leavedearler=nil
			end

			------------------------------------
			tellgameStatus(  )
		end
	end)

	-- skynet.fork(function (  )
	-- 	while true do
	-- 		skynet.sleep(50)
	-- 		os.execute("clear")
	-- 		local tmp = fruit:getGameStatus(  )
	-- 		local rightprint = {}
	-- 		table.insert(rightprint,"--------------------------")
	-- 		table.insert(rightprint,"--------------------------")
	-- 		table.insert(rightprint,"--------------------------")
	-- 		for k,v in pairs(tmp) do
	-- 			if type(v)~="table" then
	-- 			 	table.insert(rightprint,"-----"..k..":  "..v.."--------")
	-- 			end
	-- 		end
	-- 		table.insert(rightprint,"--------------------------")
	-- 		table.insert(rightprint,"--------------------------")
	-- 		table.insert(rightprint,"--------------------------")

	-- 		local leftprint = {}
	-- 		table.insert(leftprint,"--------------------------")
	-- 		table.insert(leftprint,"--------------------------")
	-- 		table.insert(leftprint,"--------------------------")
	-- 		table.insert(leftprint,"-------onlinepeople-------")
	-- 		local playert = fruit:getPlayer()
	-- 		for k,v in pairs(playert) do
	-- 			table.insert(leftprint,"-----"..k..":  "..v.."----"..fruit:getPlayerMoney(v))
	-- 		end
	-- 		table.insert(leftprint,"-------onlinepeople2-------")
	-- 		for k,v in pairs(player) do
	-- 			table.insert(leftprint,"-----"..k..":  "..v.money.."--------")
	-- 		end
	-- 		table.insert(leftprint,"-------list------------")
	-- 		playert=fruit:getDearlerList()
	-- 		for k,v in pairs(playert) do
	-- 			table.insert(leftprint,"-----"..k..":  "..v.."--------")
	-- 		end
	-- 		table.insert(leftprint,"--------------------------")
	-- 		table.insert(leftprint,"--------------------------")
	-- 		table.insert(leftprint,"--------------------------")
	-- 		if gamestatus==status.BUSY then
	-- 			print("    正在压注中------上一局开出",lastresult)
	-- 		elseif gamestatus==status.FREE then
	-- 			print("    游戏准备中------上一局开出",lastresult)
	-- 		elseif gamestatus==status.OPEN then
	-- 			print("    游戏开奖中------开出 ",lastresult)
	-- 		end
	-- 		for k,v in pairs(disconthread) do
	-- 			print("掉线玩家",k,v)
	-- 		end
	-- 		local prints="     can1fdsf                 can2fdsf                "
	-- 		for i=1,20 do
	-- 			if not leftprint[i] then
	-- 				leftprint[i]="---------------------"
	-- 			end
	-- 			if not rightprint[i] then
	-- 				rightprint[i]="---------------------"
	-- 			end
	-- 			local print2
	-- 			print2=string.gsub(prints,"can1fdsf",leftprint[i])
	-- 			print2=string.gsub(print2,"can2fdsf",rightprint[i])
	-- 			print(print2)
	-- 		end

	-- 		local a = {}
	-- 		for k,v in pairs(player) do
	-- 			table.insert(a,fruit:getPlayerStatus( k ))
	-- 		end
	-- 		print("-------------------------------------")
	-- 		for k,v in pairs(player) do
	-- 			local x = fruit:getPlayerStatus(k)
	-- 			for i,j in pairs(x) do
	-- 				if j~=0 then
	-- 					print(k,i,j)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end)

end

skynet.start(function (  )
	skynet.dispatch("lua",function ( session,source,cmd,... )
		local f = CMD[cmd]
		if f then 
			f(...)
		end
	end)
end)