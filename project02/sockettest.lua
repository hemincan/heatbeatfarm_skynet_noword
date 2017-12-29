local skynet = require "skynet"
local socket = require "socket"
local xxtea = require("xxtea")
local player = {}--frqthread

player.hemincan={frequentreq={lasttime=0,clickcount=0}}
function frequentClick( uuid )
	player[uuid].frequentreq.clickcount=player[uuid].frequentreq.clickcount+1
	if player[uuid].frequentreq.clickcount>7 then
		local time = os.time()
		if time-player[uuid].frequentreq.lasttime>1 then
			player[uuid].frequentreq.lasttime=time
			player[uuid].frequentreq.clickcount=0
			return false
		else
			print("对不起,你属于频繁点击")
			player[uuid].frequentreq.lasttime=time
			return true
		end
	end
	return false
	-- if os.time() - player[uuid].lasttime> then

	-- end
end

local cccc = {}
function cccc.b(  )
	print("what the fuck!")
end

skynet.start(function (  )
	skynet.dispatch("lua",function ( ... )
		print(cccc.b)
	end)
	skynet.fork(function (  )
		skynet.newservice("debug_console",8003)
		local fd=socket.listen("0.0.0.0",8899)
		socket.start(fd,function ( id,addr )
			socket.start(id)
			print("new connect")
			--local name = skynet.newservice("randomname")
			while true do
				local x = socket.readline(id)
				print(x,cccc.b)
				cccc.b(  )
				pcall(frequentClick,"hemincan")
				--if not x then break end
				--local x = skynet.call(name,"lua","randomname")
				--print(x)
				-- skynet.send(hourseagent,"lua",x)
			end
		end)
	end)
end)




-- if not player[uuid] then
-- 		print("此人不存在")
-- 		return
-- 	end
-- 	if player[uuid].frqthread then
-- 		print("线程已经在运行")
-- 		return
-- 	end
-- 	player[uuid].frqthread=skynet.fork(function (  )
-- 		local count = 0
-- 		while true do
-- 			if player[uuid].lasttime-os.time()>2 then
-- 				count=count+1
-- 				if count>5 then
-- 					player[uuid].frqthread=nil
-- 					break
-- 				end
-- 			end
-- 			print("我是线程!")
-- 			skynet.sleep(100)
-- 		end
-- 	end)