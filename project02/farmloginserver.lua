local skynet = require "skynet"
local socket =require "socket"
local CMD = {}
local gate=...

local function validate(  )--验证是否存在用户
	-- body   
end 

function login( fd )登录
	-- 判断是否登录成功  {"login","username","password"}
	local judge = true--validate( )
	if judge then
		local player=skynet.newservice("playeragent")
		skynet.call(player,"lua","common",fd)
		--登录成功创建代理,redis存入uuid  ("key",value) ("uuid","fd,username,......")
	else

	end

end

function register( fd )--注册
	socket.start(fd)	
	local usermsg=socket.readline(fd)--{action="register",username="username",password="password"}
	local judge=validate(  )
	if not judge then
		--存入数据库返回登录
	end

	socket.write(fd,"tologin")
end

function visitor( fd )--游客登录
	
end

function CMD.common(fd )--解码分发
	-- body
	login(fd)

end
skynet.start(function (  )
	skynet.dispatch("lua",function ( session,source,cmd,... )
		local f = CMD[cmd]
		assert(f)
		if cmd=="common" then
			f(...)
		else
			skynet.ret(skynet.pack(f(...)))
		end
	end)
end)