local skynet = require "skynet"
local dc = require "datacenter"
local cjson = require "cjson"
local json = cjson.new()
--netstat -nat|grep -i "6666"|wc -l
skynet.start(function (  )
	-- local tb={"login","username","password"}
	-- local j=json.encode(tb)
	-- print(j)
	-- local x = json.decode(j)
	-- local password = md5.hmacmd5("123")
	-- print(password,"----------")
	--skynet.newservice("testharbor")
	skynet.newservice("mysqldb")
	skynet.newservice("rankinglist")
	local db = skynet.newservice("simpledb")
	skynet.call("SIMPLEDB","lua","del","onlinepeople")
	local gate=skynet.newservice("farmgate")
	skynet.newservice("zeroupdate")
	skynet.newservice("gamecache")
	skynet.newservice("debug_console",8000)
	for i=1,10 do
		local hourseserver=skynet.newservice("hourseserver",i)
	end
	-- for i=1,1 do
	-- 	skynet.call(hourseserver,"lua","createhourse",i)
	-- end
	skynet.call(gate,"lua","open",{
		address="0.0.0.0",
		port = 6666,
		maxclient = 64,
		nodelay = true,
	})
end)