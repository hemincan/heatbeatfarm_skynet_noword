local skynet = require "skynet"
local socket = require "socket"
local CMD={}
local config = {}
local loginhandle = {}
local LOGINHANDLE_NUM = 10
local instance = 1
local MSG = {}

function calllogin( fd )--第一调用login
	skynet.send(loginhandle[instance],"lua","common",fd)
	instance=instance+1
	if instance>#loginhandle then 
		instance=1 
	end
end

function start(  )--开启监听
	local fd=socket.listen(config.address,tonumber(config.port))
	socket.start(fd,function ( fd,addr )
		skynet.error(addr,fd,"socket me!")
		skynet.fork(calllogin,fd)
	end)	
end

function CMD.disconnection( fd )
	-- body
end

function CMD.open( conf )
	config.port=conf.port
	config.address=conf.address
	for i=1,LOGINHANDLE_NUM do
		local loginserver=skynet.newservice("farmloginserver",skynet.self())
		table.insert(loginhandle,loginserver)
	end
	mainserver=server
	start()
end

skynet.start(function (  )
	skynet.dispatch("lua",function ( session,source,cmd,... )
		local f = assert(CMD[cmd])
		skynet.ret(skynet.pack(f(...)))
	end)
end)
