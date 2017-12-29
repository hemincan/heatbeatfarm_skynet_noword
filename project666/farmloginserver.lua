local skynet = require "skynet"
local socket =require "socket"
local cjson = require "cjson"
local json = cjson.new()
local md5 = require "md5"
local pack = require "pack"
local ERRORCODE =require "errorcode"
local utityhelp = require "utityhelp"
local CMD = {}
local MSG = {}
local ACTION = {}
local gate=...
local HOURSESERVER=1
function MSG.send(fd,msg )--消息发送
	msg.session=-1
	socket.write(fd,pack.encode(msg).."hello")
	print("关闭socket",fd)
	socket.close(fd)
end

local function validateregister(msg)--验证是否存在用户 msg.username
	local msg=skynet.call("mysqldb","lua","VALIDATE",msg) 
	if msg==true then--能注册
		return true
	end
	return false--不能注册
end

local function checkonline( msg )
	local user = skynet.call("SIMPLEDB","lua","HGET","onlinepeople",msg.uaccount)
	print("缓存字符串",user)
	if user then
		return true,json.decode(user)
	end
	return false
end

local function validatelogin(msg)--验证是否存在用户 msg.username，msg.userpassword
	print(msg.uaccount,msg.upassword)
	local remsg=skynet.call("mysqldb","lua","LOGINVALI",msg) 
	if remsg==true then--返回用户名值不等于空即可登陆
		return true
	else
		return false--是false
	end
end

local function validatehandshake( handshake )--验证握手码
	if handshake==nil then
		return false
	end
	local hand = skynet.call("SIMPLEDB","lua","hget","handshake",handshake)
	if hand then--握手码存在则返回真
		print("握手码是",hand)
		return true,hand
	end
	return false
end

local function validatepassword( msg )--注册验证两次密码是否相同
	if utityhelp.DelstrFl(msg.upassword)==utityhelp.DelstrFl(msg.repassword) then
		return true
	end
	return false
end 

function reconnect( fd,msg ,playeragent)
	skynet.call(math.ceil(playeragent),"lua","reconnect",fd,msg)
end

function ACTION.reconnect( fd,msg )--重连
	local isonline,user = checkonline( msg )
	-- 判断是否登录成功 
	if isonline then--判断是否属于重连
		if user.handshake==msg.handshake  then
			print("用户握手码",user.handshake,msg.handshake,"user.playeragent",user.playeragent,user.uaccount==msg.uaccount,user.upassword==msg.upassword)
			if  user.uaccount==msg.uaccount and user.upassword==msg.upassword then
				local tf,message=pcall(reconnect,fd,msg,user.playeragent)
				if not tf then
					MSG.send(fd,{action="error",code=ERRORCODE.overtime})
				end
			else
				MSG.send(fd,{action="error",code=ERRORCODE.overtime})
			end
		else
			MSG.send(fd,{action="error",code=ERRORCODE.overtime})
		end
	else
		MSG.send(fd,{action="error",code=ERRORCODE.overtime})
	end
end

function ACTION.login(fd ,msg)--登录
	print(msg.uaccount,msg.upassword,msg.handshake,"----------------帐号密码---------")
	if msg.uaccount==nil or msg.uaccount=="" then
		MSG.send(fd,{action="error",code=ERRORCODE.nameorpwdnill})
		return
	end
	local isonline,user = checkonline( msg )
	-- 判断是否登录成功 
	if isonline then--判断是否属于重连
		if user.handshake==msg.handshake  then
			skynet.error("用户握手码",user.handshake,msg.handshake,"user.playeragent",user.playeragent,user.uaccount==msg.uaccount,user.upassword,msg.upassword)
			if  user.uaccount==msg.uaccount and user.upassword==msg.upassword then
				local tf,message=pcall(reconnect,fd,msg,user.playeragent)
				if not tf then
					MSG.send(fd,{action="error",code=ERRORCODE.overtime})
				end
			else
				MSG.send(fd,{action="error",code=ERRORCODE.nameorpwd})
			end
		else
			MSG.send(fd,{action="error",code=ERRORCODE.havedlogin})
		end
	else
		local tf = validatelogin(msg)
		print(msg,tf,"登陆验证")
		if tf then--测试
			-- HOURSESERVER = HOURSESERVER+1
			-- if HOURSESERVER>10 then
			-- 	HOURSESERVER=1
			-- end
			local player=skynet.newservice("playeragent","HOURSESERVER"..HOURSESERVER)
			skynet.send(player,"lua","logincommon",fd,msg)
			--登录成功创建代理,redis存入uuid  ("key",value) ("uuid","fd,username,......")
		else
			MSG.send(fd,{action="error",code=ERRORCODE.nameorpwd})
		end
	end
end

function ACTION.register(fd ,msg)--注册
	local tf,registererrorcode = utityhelp.lawfuluaccount(msg.uaccount)
	print(tf,"fffffffff",registererrorcode)
	if not tf then
		MSG.send(fd,{action="error",code=registererrorcode})
		return
	end
	if not validatepassword(msg) then
		MSG.send(fd,{action="error",code=ERRORCODE.pwdandrepwd})
		return
	end
	local ttf,lawfulupasswordcode=utityhelp.lawfulupassword( msg.upassword )
	--print(ttf,"fffffffff",lawfulupasswordcode)
	if not ttf then
		MSG.send(fd,{action="error",code=lawfulupasswordcode})
		return
	end
	if not validateregister(msg) then
		MSG.send(fd,{action="error",code=ERRORCODE.haveduacount})
		return
	end
	msg.upassword=utityhelp.DelstrFl(msg.upassword)
	msg.uaccount=utityhelp.DelstrFl(msg.uaccount)
	msg.username=utityhelp.DelstrFl(msg.username)
	local isregister=skynet.call("mysqldb","lua","register",msg)
	--print("isregister",isregister)
	if isregister then
		-- HOURSESERVER = HOURSESERVER+1
		-- if HOURSESERVER>2 then
		-- 	HOURSESERVER=1
		-- end		
		local player=skynet.newservice("playeragent","HOURSESERVER"..HOURSESERVER)
		skynet.send(player,"lua","registercommon",fd,msg)
	else
		MSG.send(fd,{action="error",code=ERRORCODE.registerfailed})
		return
	end
end

function visitoruaccount(currenvisitorid)
	local uaccount
	uaccount = "yk"..string.format("%08d",tonumber(currenvisitorid)+1)
	return uaccount,uaccount..string.sub(os.date("%Y%m%d%H%M",tonumber(os.time())),3)
end

function createplayer( fd,msg )
	local  user={}
	local previous=skynet.call("SIMPLEDB","lua","get","currenvisitorid")
	user.uaccount,user.upassword = visitoruaccount(previous)
	user.username=string.sub(user.uaccount,3)
	user.vid=string.format("%08d",tonumber(previous)+1)
	print("游客2",user.uaccount,user.username,user.vid)
	local msg=skynet.call("mysqldb","lua","VISITOR",user)	
	skynet.call("SIMPLEDB","lua","set","currenvisitorid",user.vid)
	if msg then
		-- HOURSESERVER = HOURSESERVER+1
		-- if HOURSESERVER>2 then
		-- 	HOURSESERVER=1
		-- end		
		local player=skynet.newservice("playeragent","HOURSESERVER"..HOURSESERVER)
		skynet.send(player,"lua","visitorcommom",fd,user)
	end	
end

function ACTION.visitor( fd ,msg)--游客登录，游客一些数据也必须记入数据库
	if msg.uaccount~=nil then
		local isonline,user = checkonline( msg )
		if isonline then
			print("isonline=",isonline)
			if user.handshake==msg.handshake then
				if  user.uaccount==msg.uaccount and user.upassword==msg.upassword then
					skynet.call(math.ceil(user.playeragent),"lua","reconnect",fd,msg)
				else
					MSG.send(fd,{action="error",code=ERRORCODE.nameorpwd})
				end			
			else
				local tf,message=pcall(reconnect,fd,msg,user.playeragent)
				if not tf then
					MSG.send(fd,{action="error",code=ERRORCODE.overtime})
				end
				--MSG.send(fd,{action="error",code=ERRORCODE.havedlogin})
			end
			return
		end
		local judge = skynet.call("mysqldb","lua","VALIACC",msg)
		print("是否存在该账户",judge)
		if judge then
			--local visitormsg = skynet.call("mysqldb","lua","select",msg)
			local tf = validatelogin(msg)
			print(msg,tf,"登陆验证")
			if tf then--测试
				-- HOURSESERVER = HOURSESERVER+1
				-- if HOURSESERVER>2 then
				-- 	HOURSESERVER=1
				-- end				
				local player=skynet.newservice("playeragent","HOURSESERVER"..HOURSESERVER)
				skynet.send(player,"lua","visitorcommom",fd,msg)
				--登录成功创建代理,redis存入uuid  ("key",value) ("uuid","fd,username,......")
			else
				createplayer( fd,msg )
			end	
		else
			createplayer( fd,msg )
		end
	else
		createplayer( fd,msg )
	end
end

function ACTION.heart( msg)--游客登录，游客一些数据也必须记入数据库
end

local people = {}
function CMD.common(fd)--解码分发
	socket.start(fd)
	skynet.fork(function (  )
		local heartbreak=30
		while true do
			skynet.sleep(50)
			if people[fd]~=nil then
				break
			end
			heartbreak=heartbreak-1
			if heartbreak<0 then
				print("login socket关闭")
				--socket.close(fd)
				break
			end
		end
	end)
	skynet.fork(function (  )
		usermsg=socket.readline(fd,"hello")
		if usermsg==false then
			print("usermsg==false" )
			socket.close(fd)
		else
			people[fd]=1
			--socket.write(fd,json.encode({action="login"}).."\n")
			local tf,message=pcall(pack.decode,usermsg)
			print(message,"解压信息")
			if tf then
				if message.action~=nil then
					--skynet.error(message.action,"动作")
					local f = ACTION[message.action]
					if f then
						skynet.error(message.action,"动作")
						f(fd,message)
					else
						socket.close(fd)
					end
				end
			end
		end	
	end)
end

skynet.start(function(  )
	skynet.dispatch("lua",function ( session,source,cmd,... )
		local f = assert(CMD[cmd])
		if cmd=="common" then
			f(...)
		else
			skynet.ret(skynet.pack(f(...)))
		end
	end)
end)