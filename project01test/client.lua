local skynet=require "skynet"
skynet.start(function (  )
	local name = "incre"
	skynet.fork(function (  )
		for i=1,300 do
			skynet.sleep(10)
			local client=skynet.newservice("clientagent",name..i)
		end
	end)
	skynet.fork(function (  )
		for i=301,600 do
			skynet.sleep(10)
			local client=skynet.newservice("clientagent",name..i)
		end
	end)
	-- skynet.fork(function (  )
	-- 	for i=601,800 do
	-- 		skynet.sleep(10)
	-- 		local client=skynet.newservice("clientagent",name..i)
	-- 	end
	-- end)
	
	-- skynet.fork(function (  )
	-- 	for i=801,999 do
	-- 		skynet.sleep(10)
	-- 		local client=skynet.newservice("clientagent",name..i)
	-- 	end
	-- end)
	

	-- local name = "cccc"
	-- skynet.fork(function (  )
	-- 	for i=1,300 do
	-- 		skynet.sleep(10)
	-- 		local client=skynet.newservice("clientagent",name..i)
	-- 	end
	-- end)
	-- skynet.fork(function (  )
	-- 	for i=301,600 do
	-- 		skynet.sleep(10)
	-- 		local client=skynet.newservice("clientagent",name..i)
	-- 	end
	-- end)
	-- skynet.fork(function (  )
	-- 	for i=601,800 do
	-- 		skynet.sleep(10)
	-- 		local client=skynet.newservice("clientagent",name..i)
	-- 	end
	-- end)
	
	-- skynet.fork(function (  )
	-- 	for i=801,999 do
	-- 		skynet.sleep(10)
	-- 		local client=skynet.newservice("clientagent",name..i)
	-- 	end
	-- end)

	-- local name = "www"
	-- skynet.fork(function (  )
	-- 	for i=1,1000 do
	-- 		skynet.sleep(10)
	-- 		local client=skynet.newservice("clientagent",name..i)
	-- 	end
	-- end)


end)