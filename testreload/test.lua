local skynet = require "skynet"
local i = 10

skynet.start(function()
	skynet.fork(function (  )
		while true do
			skynet.sleep(100)
			skynet.error("hello bo222y",i)
			i=i+1
		end
	end)
	skynet.dispatch("lua", function(_,_,msg)
		skynet.sleep(100)
		--skynet.ret(skynet.pack(msg))
	end)
end)
