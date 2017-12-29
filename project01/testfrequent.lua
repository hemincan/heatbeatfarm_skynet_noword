local skynet = require "skynet"
local socket = require "socket"
math.randomseed(os.time())
skynet.start(function (  )
	local fd = socket.open("127.0.0.1",8888)
	local x = 1
	local time = {10,50}
	skynet.fork(function (  )
		while true do
			skynet.sleep(math.random(time[#time]))
			skynet.error(x)
			socket.write(fd,x.."\n")
			x=x+1
		end
	end)
end)