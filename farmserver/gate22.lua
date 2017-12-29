local skynet = require "skynet"
local socket = require "socket"
local cjson = require "cjson"
local json = cjson.new()
skynet.start(function (  )
	skynet.fork(function (  )
		local fd=socket.listen("0.0.0.0",8888)
		socket.start(fd,function ( id,addr )
			skynet.error(addr,"sdfsdfsdfdf")
			skynet.fork(function (  )
				socket.start(id)
				skynet.fork(function (  )
						while true do
							socket.write(id,"{\"action\":\"hello\",\"session\":2}\n")
							skynet.sleep(300)
						end
					end)
				while true do

					socket.write(id,"{\"action\":\"hello\",\"session\":2}\n")
					local x = socket.readline(id)
					print(x)
					local s,dd = pcall(json.decode,x)
					print(s,dd)
					-- socket.close(id)
					if not x then 
						print("socket close!")
						break 
					end
			end
			end)
		end)
	end)
	skynet.sleep(100)
	for i=1,5 do
		skynet.newservice("client")
	end
		
	
end)