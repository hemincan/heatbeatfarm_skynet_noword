local skynet=require "skynet"

function s(  )
	skynet.sleep(500)
end

skynet.start(function (  )
	skynet.dispatch("lua",function (  )
		local x=skynet.mqlen()
		print("消息队列:",x)
		skynet.ret(skynet.pack(s()))
	end)
end)