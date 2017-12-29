local skynet=require "skynet"

skynet.start(function (  )
	skynet.fork(function (  )
		while true do
			skynet.newservice("calltest")
			skynet.sleep(200)
		end
	end)

end)