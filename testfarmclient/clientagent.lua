local skynet = require "skynet"
local socket = require "socket"

local cjson = require "cjson"
local md5 = require "md5"
local json = cjson.new()
local pack = require "pack"

function printtable( t ,s)
	s=s..s
	for k,v in pairs(t) do
		print(s,k,v)
		if type(v)=="table" then
			printtable(v,s)
		end
	end
end
local result
local seed
local count = 0
skynet.start(function (  )
	-- local cmdtable={}
	local cmdtable = {{action="getyesdaylist"},{action="getyesdayalllist"}}

	table.insert(cmdtable,{action="yanangua",money="50000"})
	table.insert(cmdtable,{action="yagangzhe",money="50000"})
	table.insert(cmdtable,{action="yamogu",money="50000"})
	table.insert(cmdtable,{action="yaguangchangsu",money="50000"})
	table.insert(cmdtable,{action="yayidianhong",money="50000"})
	table.insert(cmdtable,{action="yawandou",money="50000"})
	-----------------------------------------------------
	-- table.insert(cmdtable,{action="fastinnerHourse"})
	-- table.insert(cmdtable,{action="wantdealer"})
	-- table.insert(cmdtable,{action="getonlinepeople"})
	-- table.insert(cmdtable,{action="gethistorylist"})
	-- table.insert(cmdtable,{action="exitdearlerlist"})
	-- table.insert(cmdtable,{action="leavehourse"})
	-- table.insert(cmdtable,{action="exitdealer"})
	--table.insert(cmdtable,{action="getgamestatus"})

	 -- local fd = socket.open("192.168.83.142",6666)
	local fd = socket.open("60.205.179.119",6666)
	--local fd = socket.open("127.0.0.1",8888)
	skynet.fork(function (  )
		--skynet.sleep(10)
		local str = pack.encode({action="login",uaccount="xiexie",upassword="123456",handshake="c99bc00a19d0cb9063ea002f4c3f9895" })--{uaccount="12444242",upassword="upassword",username="hello4",handshake="8"}
		printtable(pack.decode(str),"$$")
		socket.write(fd,str.."hello")--
		skynet.sleep(10)
		local str = pack.encode({action="createhourse"})
		socket.write(fd,str.."hello")

		skynet.sleep(200)
		 seed = os.time()
		
		while true do
			math.randomseed(seed)
			skynet.sleep(1000)
			result = getResult( )
			count=count+1
			local x = {action="ya"..result,money="500"}
			print(result,result,result,result)
			socket.write(fd,pack.encode(x).."hello")
			skynet.sleep(2000)
			-- local t = cmdtable[math.random(1,#cmdtable)]
			-- local str = pack.encode(t)
			-- --print("$$$$$$$$$$$$$$$$$$$$$$$",t.action)
			-- socket.write(fd,str.."hello")
			-- --socket.write(fd,"str".."hello")
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
			if not msg then
				break
			end
			local msgjson = msg
			--print("原始值",msg)
			local msg = pack.decode(msg)

			if msg.action=="gamestatus" then
				--os.execute("clear")
				--print(#msg.onlinepeople)
				printtable( msg ,"--")
			elseif msg.action=="result" then
				print("result---------------",msg.result,msg.session)
				if msg.result~=result then
					seed=seed+1
					for i=1,count do
						getResult()
					end
					count=0
				end
			-- elseif msg.action=="prepare" then
			-- 	print("status---------------","prepare",msg.session)
			-- elseif msg.action=="busy" then
			-- 	print("status---------------","busy",msg.session)
			elseif msg.action=="onlinepeople" then
				--printtable( msg ,"@@")
			elseif msg.action=="history" then
				-- printtable( msg ,"@@")
			elseif msg.action=="yesdaylist" then
				-- printtable( msg ,"@@")
			elseif msg.action=="yesdayalllist" then
				-- printtable( msg ,"@@")
			end

		end
	end)
	skynet.fork(function (  )
		while true do 
			socket.write(fd,pack.encode({action="heart"}).."hello")
			skynet.sleep(100)
		end
	end)
end)