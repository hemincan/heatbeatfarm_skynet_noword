local skynet = require "skynet"
local socket = require "socket"
local frequentclick = 
{   frequentthreadran = false,
	lasttime = os.time(),
	count = 0,
	message={},
}
function click( x )
	frequentclick.message=x
	if os.time()==frequentclick.lasttime then
		 -- print("密集点击")
		--密集点击
		frequentclick.count=0--重置线程中的count,密码点击停下之后便可更新
		if not frequentclick.frequentthreadran then--没创建过这个线程
			frequentclick.frequentthreadran = true
			skynet.fork(function (  )
				while true do
					skynet.sleep(15)
					--print("thread run")
					frequentclick.count=frequentclick.count+1
					if frequentclick.count < 0 then
						break
					end
					if frequentclick.count>=5 then
						--发送消息
						print(frequentclick.message)
						frequentclick.frequentthreadran=false
						break
					end
				end
			end)
		end
	else
		frequentclick.count=-1--线程可以停了,给一个负数
		frequentclick.lasttime=os.time()
		--发送消息
		print(frequentclick.message)
	end
end
skynet.start(function (  )
	skynet.fork(function (  )
		local fd=socket.listen("0.0.0.0",8888)
		socket.start(fd,function ( id,addr )
			socket.start(id)
			while true do
				local x = socket.readline(id)
				if not x then print("bye") break end
				click(x)
			end
		end)
	end)
	skynet.newservice("testfrequent")
end)