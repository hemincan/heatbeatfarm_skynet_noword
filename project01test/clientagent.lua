local skynet = require "skynet"
local socket = require "socket"

local cjson = require "cjson"
local json = cjson.new()
local pack = require "pack"
local ERROTCODE = require "errorcode"

local uaccount = ...

math.randomseed(os.time())

function cmdplaygame(  )
	local cmdtable = {}
	

	table.insert(cmdtable,{action="yaluobo",money="500000"})
	table.insert(cmdtable,{action="yawandou",money="500000"})
	table.insert(cmdtable,{action="yanangua",money="500000"})
	table.insert(cmdtable,{action="yabaicai",money="500000"})
	table.insert(cmdtable,{action="yagangzhe",money="500000"})
	table.insert(cmdtable,{action="yamogu",money="500000"})
	table.insert(cmdtable,{action="yaguangchangsu",money="500000"})
	table.insert(cmdtable,{action="yayidianhong",money="500000"})

	table.insert(cmdtable,{action="yaluobo",money="500000"})
	table.insert(cmdtable,{action="yawandou",money="500000"})
	table.insert(cmdtable,{action="yanangua",money="500000"})
	table.insert(cmdtable,{action="yabaicai",money="500000"})
	table.insert(cmdtable,{action="yagangzhe",money="500000"})
	table.insert(cmdtable,{action="yamogu",money="500000"})
	table.insert(cmdtable,{action="yaguangchangsu",money="500000"})
	table.insert(cmdtable,{action="yayidianhong",money="500000"})

		table.insert(cmdtable,{action="yaluobo",money="500000"})
	table.insert(cmdtable,{action="yawandou",money="500000"})
	table.insert(cmdtable,{action="yanangua",money="500000"})
	table.insert(cmdtable,{action="yabaicai",money="500000"})
	table.insert(cmdtable,{action="yagangzhe",money="500000"})
	table.insert(cmdtable,{action="yamogu",money="500000"})
	table.insert(cmdtable,{action="yaguangchangsu",money="500000"})
	table.insert(cmdtable,{action="yayidianhong",money="500000"})

	table.insert(cmdtable,{action="yaluobo",money="500000"})
	table.insert(cmdtable,{action="yawandou",money="500000"})
	table.insert(cmdtable,{action="yanangua",money="500000"})
	table.insert(cmdtable,{action="yabaicai",money="500000"})
	table.insert(cmdtable,{action="yagangzhe",money="500000"})
	table.insert(cmdtable,{action="yamogu",money="500000"})
	table.insert(cmdtable,{action="yaguangchangsu",money="500000"})
	table.insert(cmdtable,{action="yayidianhong",money="500000"})

	table.insert(cmdtable,{action="yaluobo",money="500000"})
	table.insert(cmdtable,{action="yawandou",money="500000"})
	table.insert(cmdtable,{action="yanangua",money="500000"})
	table.insert(cmdtable,{action="yabaicai",money="500000"})
	table.insert(cmdtable,{action="yagangzhe",money="500000"})
	table.insert(cmdtable,{action="yamogu",money="500000"})
	table.insert(cmdtable,{action="yaguangchangsu",money="500000"})
	table.insert(cmdtable,{action="yayidianhong",money="500000"})
	table.insert(cmdtable,{action="sendmessage",mess="给我往死里压"})
	table.insert(cmdtable,{action="sendmessage",mess="出一点红就好了"})
	table.insert(cmdtable,{action="sendmessage",mess="我是小宝宝"})
	-----------------------------------------------------------------
	table.insert(cmdtable,{action="wantdealer"})
	table.insert(cmdtable,{action="leavehourse"})
	-- table.insert(cmdtable,{action="getonlinepeople"})
	--table.insert(cmdtable,{action="exitdearlerlist"})
	table.insert(cmdtable,{action="exitdealer"})
	table.insert(cmdtable,{action="exitdearlerlist"})
	return cmdtable
end

function cdmhourse(  )
	local cmdtable = {}
	return cmdtable
end

function cmdlogin(  )
	local cmdtable = {}
	return cmdtable
end

function printtable( t ,s)
	s=s..s
	for k,v in pairs(t) do
		print(s,k,v)
		if type(v)=="table" then
			printtable(v,s)
		end
	end
end
function seedmsg( fd,tab )
	--print(json.encode(tab),"json data")
	socket.write(fd,pack.encode(tab).."hello")
end

skynet.start(function (  )
	-- local fd = socket.open("192.168.83.14",6666)--60.205.179.119,192.168.83.142 www.mircan.top
	local fd = socket.open("60.205.179.119",6666)
	-- local fd = socket.open("192.168.83.142",6666)
	skynet.fork(function(  )
		--skynet.sleep(10)
		--local str = {action="login",uaccount="test1",upassword="123456",handshake="c99bc00a19d0cb9063ea002f4c3f9895",visitor=0 }--{uaccount="12444242",upassword="upassword",username="hello4",handshake="8"}
		--seedmsg( fd,{action="register",uaccount=uaccount,repassword="www.cc+",username=uaccount,upassword="www.cc+"})
		-- skynet.sleep(10)
		-- --local str = {action="editeusername",username="xwx1014",newusername="xwh1014"}
		-- --local str = json.encode({action="fastinnerHourse"})
		-- seedmsg(fd,{action="editpassword",upassword="123456",uid="49"})
		seedmsg(fd,{action="login",uaccount=uaccount,upassword="www.cc+",handshake="xwx001@14:06:07",visitor=0 })
		--seedmsg(fd,{action="visitor",uaccount="yk00000129",upassword="yk000001291702101040",handshake="yk00000129@14:03:53",visitor=1 })
		--skynet.sleep(10)
		--seedmsg(fd,{action="reconnect",uaccount=uaccount,upassword="123456",handshake="xwx001@10:31:20",visitor=0 })
		skynet.sleep(200)
			-- if tonumber(string.match(uaccount,"%d+"))%2==0 then
				seedmsg(fd,{action="fastinnerHourse"})
			-- else
			-- 	seedmsg(fd,{action="createhourse"})
			-- end
		print(uaccount)
		--seedmsg(fd,{action="createhourse"}) 
		--seedmsg(fd,{action="editeusername",newusername="00000129"}) 
		--seedmsg(fd,{action="editupassword",upassword="",})
		-- -- skynet.sleep(10)
		

		--seedmsg(fd,{action="editbankpassword",bpassword="666666",newbpassword="12345678"})
		--seedmsg(fd,{action="initrewards"})

		--seedmsg(fd,{action="Recharge",cash=4000000000,uaccount="谢武幸"})
		-- -- -- seedmsg(fd,{action="Recharge",cash=200000000,uaccount="yk00000048"})
		-- -- -- seedmsg(fd,{action="Recharge",cash=200000000,uaccount="hemincan"})
		-- skynet.sleep(10)
		--seedmsg(fd,{action="fastinnerHourse"})
		-- skynet.sleep(10)
		--seedmsg(fd,{action="onlineRewards"})
		--[[
		skynet.sleep(10)
		seedmsg(fd,{action="depositbank",money="2000"})
		skynet.sleep(10)
		seedmsg(fd,{action="Withdrawbank",money="11"})
		skynet.sleep(10)
		
		--]]
		--seedmsg(fd,{action="onlineRewards"})
		-- -- -- --seedmsg(fd,{action="getgamestatus"})
		-- -- -- --seedmsg( fd,{action=cd sk"hoursehall",page=1})
		-- -- -- -- skynet.sleep(200)
		-- -- -- -- --------------------------------------------------------------
		-- skynet.sleep(10)
		local cmdplaygame = cmdplaygame()
		local count = 0
		while true do
			skynet.sleep(100)
			local t = cmdplaygame[math.random(1,#cmdplaygame)]
			if t.action=="leavehourse" then
				seedmsg(fd,t)
				skynet.sleep(2000)
				seedmsg(fd,{action="fastinnerHourse"})
			else
				seedmsg(fd,t)
				count=count+1
				if count>50 then
					
					count = 0
				end
				skynet.sleep(100)
			--seedmsg( fd,{action="getonlinepeople"})
			end
		end
		

		-- {action="yabaicai",money=""}
		-- {action="yawandou",money=""}
		-- {action="yanangua",money=""}
		-- {action="yagangzhe",money=""}
		-- {action="yamogu",money=""}
		-- {action="yaguangchangsu",money=""}
		-- {action="yayidianhong",money=""}

		-- {action="wantdealer"}--排队上庄
		-- {action="exitdearlerlist"}--退出排除队列
		-- {action="exitdealer"}--庄家，取消当庄家，

		-- local str = json.encode({action="leavehourse"})
		-- socket.write(fd,str.."hello")
		
		-- skynet.sleep(1000)
		-- local str = json.encode({action="logout"})
		-- socket.write(fd,str.."hello")
	end)
	skynet.fork(function (  )
		while true do
			local msg=socket.readline(fd,"hello")
			--print(msg,"接收原始编码")
			if not msg then
				break
			end
			local msgjson = msg
			local msgmsg = pack.decode(msg)
			printtable(msgmsg,"**")
			if msgmsg.action~=nil then
				if msgmsg.action=="gamestatus" then
					--os.execute("clear")
					--printtable( msgmsg ,"--")
				elseif msgmsg.action=="result" then
					--print("游戏结果",msgmsg.result)
				elseif msgmsg.action=="error" then
					--print(ERROTCODE[msgmsg.code])
				elseif msgmsg.action=="messsage" then
					local x = math.random(40)
					if x==1 then
						--seedmsg(fd,{action="sendmessage",mess="哦"})
					end
					if x==2 then
						--seedmsg(fd,{action="sendmessage",mess="我也觉得!"})
					end
				end
			end
		end
	end)
	skynet.fork(function (  )
		while true do 
			seedmsg(fd,{action="heart"})
			skynet.sleep(1000)
		end
	end)
end)