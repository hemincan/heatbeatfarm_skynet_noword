local skynet=require "skynet"
skynet.start(function (  )
	-- local x = skynet.call("TESTHARBOR","lua","get","hhh")
	-- print(x,"ssssssssssssssss")
	skynet.fork(function (  )
		for i=1,1 do
			--skynet.sleep(1)
			-- local client=skynet.newservice("clientagentnopack")
			local client=skynet.newservice("clientagent")
		end
	end)
	
	-- skynet.fork(function (  )
	-- 	for i=1,100 do
	-- 		skynet.sleep(3)
	-- 		local client=skynet.newservice("clientagent")
	-- 	end
	-- end)
	-- skynet.fork(function (  )
	-- 	for i=1,100 do
	-- 		skynet.sleep(5)
	-- 		local client=skynet.newservice("clientagent")
	-- 	end
	-- end)
	-- skynet.fork(function (  )
	-- 	skynet.sleep(7)
	-- 	for i=1,100 do
	-- 		skynet.sleep(7)
	-- 		local client=skynet.newservice("clientagent")
	-- 	end
	-- end)	
end)