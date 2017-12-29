

local inp = assert(io.open("jpg.jpg","r"))
local x = inp:read("*all")
print(x)
local out = assert(io.open("aa.jpg","w"))
out:write(x)
sdkfjlaskdjfl
out:close()
print(x)