local crypt = require "crypt"
local skynet = require "skynet"

skynet.start(function (  )
	for k,v in pairs(crypt) do
		print(k,v)
	end
end)

