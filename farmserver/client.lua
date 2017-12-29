local skynet = require "skynet"
local socket = require "socket"

skynet.start(function (  )
	skynet.fork(function (  )
		local id=socket.open("127.0.0.1",8888)
		for i=1,5 do
			skynet.sleep(50)
			socket.write(id,"sdfsadfasdf\n")
		end
		socket.close(id)
		
	end)
end)