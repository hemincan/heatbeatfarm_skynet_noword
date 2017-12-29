local skynet = require "skynet"
skynet.start(function (  )
	local currenvid=skynet.call("mysqldb","lua","SETVID")
	if not currenvid then
		skynet.call("SIMPLEDB","lua","set","currenvisitorid","00000001")
	else
		skynet.call("SIMPLEDB","lua","set","currenvisitorid",currenvid)		
	end
end)