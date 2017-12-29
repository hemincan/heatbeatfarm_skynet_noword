local skynet = require "skynet"
local socket = require "socket"
local x = 1
local dc = require "datacenter"
require "skynet.manager"
local cjson = require "cjson"
local json = cjson.new()
local socketid
math.randomseed(os.time())
skynet.start(function (  )
	-- local tb={"login","username","password"}
	-- local j=json.encode(tb)
	-- print(j)
	-- local x = json.decode(j)
	skynet.newservice("debug_console",8000)
	local hourseagent=skynet.newservice("hourseagent")
	skynet.send(hourseagent,"lua","start")
	skynet.send(hourseagent,"lua","newplayer","hemincan",50000000)
	skynet.send(hourseagent,"lua","newplayer","aaaaaaaa",50000000)
	skynet.send(hourseagent,"lua","newplayer","bbbbbbbb",50000000)
	skynet.send(hourseagent,"lua","newplayer","cccccccc",50000000)
	skynet.send(hourseagent,"lua","newplayer","dddddddd",50000000)
	local user = {}
	table.insert(user,"hemincan")
	--table.insert(user,"aaaaaaaa")
	table.insert(user,"bbbbbbbb")
	table.insert(user,"cccccccc")
	table.insert(user,"dddddddd")
	local class	= {	
	"yaluobo",
	"yabaicai",
	"yawandou",
	"yanangua",
	"yagangzhe",
	"yamogu",
	"yaguangchangsu",
	"yayidianhong"}
	-- skynet.send(hourseagent,"lua","wantdealer","hemincan")
	-- -- skynet.send(hourseagent,"lua","wantdealer","aaaaaaaa")
	-- skynet.send(hourseagent,"lua","wantdealer","bbbbbbbb")
	-- skynet.send(hourseagent,"lua","wantdealer","cccccccc")
	-- skynet.send(hourseagent,"lua","wantdealer","dddddddd")
	skynet.fork(function (  )
		local fd=socket.listen("0.0.0.0",8888)
		socket.start(fd,function ( id,addr )
			socket.start(id)
			socketid=id
			print("new socket",id,addr)
			while true do
				local x = socket.readline(id)
				skynet.error(x)
				if not x then 
					print("have closed")
					break
				end
				skynet.send(hourseagent,"lua",x,"aaaaaaaa",23000)
			end
		end)
	end)

	skynet.fork(function (  )
		while true do
			-- local x = math.random(8)
			-- local us = math.random(5)
			-- skynet.send(hourseagent,"lua",class[x],user[us],20000)
			-- skynet.sleep(200)
			-- --skynet.send(hourseagent,"lua","wantdealer","hemincan")

			local us = math.random(4)
			local x = math.random(8)
			--skynet.send(hourseagent,"lua","wantdealer",user[us])
			skynet.send(hourseagent,"lua",class[x],user[us],200000)
			skynet.sleep(200)

		end
	end)
	-- local db = skynet.newservice("simpledb")
	-- local gate=skynet.newservice("farmgate")
	-- local hourseserver=skynet.newservice("hourseserver")
	-- skynet.call(gate,"lua","open",{
	-- 	address="192.168.83.142",
	-- 	port = 8888,
	-- 	maxclient = 64,
	-- 	nodelay = true,
	-- })
	skynet.register "TESTSERVER"
	local CMD = {}
	function CMD.tellagent(...)
		local m=json.encode(...)
		skynet.error(m)
		if socketid then
			socket.write(socketid,m.."\n")
		end
	end
	skynet.dispatch("lua",function ( session,source,cmd,... )
		local f = CMD[cmd]
		if f then 
			f(...)
		end
	end)
end)