local skynet = require "skynet"
local socket = require "socket"

local cjson = require "cjson"
local md5 = require "md5"
local json = cjson.new()

math.randomseed(os.time())

function printtable( t ,s)
	s=s..s
	for k,v in pairs(t) do
		print(s,k,v)
		if type(v)=="table" then
			printtable(v,s)
		end
	end
end

skynet.start(function (  )
	local cmdtable={}
	-- local cmdtable = {{action="yaluobo",money="50000"},{action="yabaicai",money="50000"}}

	-- table.insert(cmdtable,{action="yanangua",money="50000"})
	-- table.insert(cmdtable,{action="yagangzhe",money="50000"})
	table.insert(cmdtable,{action="yamogu",money="50000"})
	-- table.insert(cmdtable,{action="yaguangchangsu",money="50000"})
	-- table.insert(cmdtable,{action="yayidianhong",money="50000"})
	table.insert(cmdtable,{action="yawandou",money="100000"})
	-----------------------------------------------------
	table.insert(cmdtable,{action="fastinnerHourse"})
	--table.insert(cmdtable,{action="wantdealer"})
	--table.insert(cmdtable,{action="exitdearlerlist"})
	--table.insert(cmdtable,{action="leavehourse"})
	-- table.insert(cmdtable,{action="exitdealer"})
	table.insert(cmdtable,{action="getgamestatus"})

	local fd = socket.open("192.168.83.142",8888)
	skynet.fork(function (  )
		--skynet.sleep(10)
		local str = json.encode({action="login",uaccount="hemincan",upassword="123456",handshake="c99bc00a19d0cb9063ea002f4c3f9895" })--{uaccount="12444242",upassword="upassword",username="hello4",handshake="8"}
		print(str,"-----")
		socket.write(fd,str.."\n")--
		skynet.sleep(10)
		local str = json.encode({action="fastinnerHourse"})
		socket.write(fd,str.."\n")
		local str = json.encode({action="fastinnerHourse"})
		socket.write(fd,str.."\n")
		skynet.sleep(200)

		while true do
			skynet.sleep(50)
			local t = cmdtable[math.random(1,#cmdtable)]
			local str = json.encode(t)
			--print("$$$$$$$$$$$$$$$$$$$$$$$",t.action)
			socket.write(fd,str.."\n")
			socket.write(fd,"str".."\n")
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
		-- socket.write(fd,str.."\n")
		
		-- skynet.sleep(1000)
		-- local str = json.encode({action="logout"})
		-- socket.write(fd,str.."\n")
	end)
	skynet.fork(function (  )
		while true do
			local msg=socket.readline(fd)
			if not msg then
				break
			end
			print("receive:----------",msg)
			local msgjson = msg
			local msg = json.decode(msg)

			if msg.action=="gamestatus" then
				--os.execute("clear")
				--print(#msg.onlinepeople)
				printtable( msg ,"--")
			elseif msg.action=="result" then
				print("result---------------",msg.result,msg.session)
			-- elseif msg.action=="prepare" then
			-- 	print("status---------------","prepare",msg.session)
			-- elseif msg.action=="busy" then
			-- 	print("status---------------","busy",msg.session)
			elseif msg.action=="onlinepeople" then
				printtable( msg ,"@@")
			end

		end
	end)
	skynet.fork(function (  )
		while true do 
			socket.write(fd,json.encode({action="heart"}).."\n")
			skynet.sleep(100)
		end
	end)
end)