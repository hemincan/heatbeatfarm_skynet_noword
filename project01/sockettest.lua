local skynet = require "skynet"
local socket = require "socket"

skynet.start(function (  )
	local hourseagent=skynet.newservice("hourseagent")
	skynet.fork(function (  )
		local fd=socket.listen("0.0.0.0",8888)
		socket.start(fd,function ( id,addr )
			socket.start(id)
			while true do
				local x = socket.readline(id)
				if not x then break end
				skynet.send(hourseagent,"lua",x)
			end
		end)
	end)
end)