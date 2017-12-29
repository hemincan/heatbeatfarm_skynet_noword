local skynet = require "skynet"

local CMD = {}
function CMD.test( ... )
	print("call me!")
	skynet.sleep(1000)
end

skynet.start(function (  )
	print("hello!!!!!,!!!!!!!!!!!!!!!!!!")
skynet.dispatch("lua",function ( _,_,cmd,... )
	local f = CMD[cmd]
	if f then
		skynet.ret(skynet.pack(f(...)))
	end
end)	
end)
