-- local skynet = require "skynet"
-- skynet.start(function (  )
-- 	skynet.dispatch("lua",function (  )
		
-- 	end)
-- end)

local hotfix = require "hellohotfix"

function newnew(  )
	local old_module = require("hellohotfix")
	package.loaded["hellohotfix"] = nil
    local new_module = require("hellohotfix")
    for k,v in pairs(new_module) do
        old_module[k] = v
    end
    package.loaded["hellohotfix"]  = old_module
end

for i=1,10 do
	hotfix.add()
	os.execute("sleep 2s")
	if i==4 then
		newnew()
	end
end

