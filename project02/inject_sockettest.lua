-- if not _P then
--   print "inject error!!"
--   return
-- end
-- local command = _P.lua.cccc
-- command.TEST = function() return "TEST" end
 
-- print "inject ok!"

-- for k,v in pairs(_ENV._U) do
-- 	print(k,v)
-- end
-- local s =debug.getlocal(1,1)
-- local t = _P.lua
-- for k,v in pairs(t) do
-- 	print(k,v)
-- end

-- -- function _P.lua.cccc.b(  )
-- -- 	local a = 1
-- -- 	local b = 2
-- -- 	print(a+b)
-- -- end


-- local new = _P.lua.cccc
-- local print_ = _P.lua._ENV.print
-- _P.lua._ENV.helloword=function (  )
-- 	print_("helloworfghdfgdfd")
-- end
-- _P.lua._ENV.frequentClick=function ( uuid )
-- 	local a,b = 56,14,1
-- 	print_(uuid,a,b,"sadfadf")
-- end
-- new.c="i am a new c!"
-- new.b=function (  )
-- 	print_("falksdjflakjdfdfgdfgdfg22222222l")
-- 	print_(new.c)
-- 	_P.lua._ENV.helloword()
-- end
local reload = require "reload"
reload()
print("wocaoisdf")