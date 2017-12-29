local skynet=require "skynet"
skynet.start(function (  )
	local client=skynet.newservice("clientagent")
	for i=1,2000 do
		skynet.fork(function (  )
			for i=1,1000 do
				skynet.call(client,"lua","Sdfs")
				-- skynet.error("one:",i)
			end
		end)
	end

end)