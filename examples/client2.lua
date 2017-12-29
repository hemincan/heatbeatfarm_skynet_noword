package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;examples/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"


local fd = assert(socket.connect("127.0.0.1", 8888))

local function send_request(pack)
	socket.send(fd, pack.."\n")
end

-- math.randomseed(os.time())
-- local class	= {	
-- 	"yaluobo",
-- 	"yabaicai",
-- 	"yawandou",
-- 	"yanangua",
-- 	"yagangzhe",
-- 	"yamogu",
-- 	"yaguangchangsu",
-- 	"yayidianhong"}
-- while true do
-- 	local x = math.random(8)	
-- 	print(class[x])
-- 	os.execute("sleep 0.5s")
-- end


while true do
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "quit" then
			send_request("quit")
		else
			send_request(cmd)
		end
	else
		socket.usleep(100)
	end
end
