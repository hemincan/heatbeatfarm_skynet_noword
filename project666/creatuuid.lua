local UUID={}
function UUID.new(  )
	local template ="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	d = io.open("/dev/urandom", "r"):read(4)
	math.randomseed(os.time() + d:byte(1) + (d:byte(2) * 256) + (d:byte(3) * 65536) + (d:byte(4) * 4294967296))
	return string.gsub(template, "x", function (c)
	      local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
	      return string.format("%x", v)
	      end)
end
return UUID
-- print(os.date("%H:%M:%S"))
-- print(os.date("%X"))
---------------------
-- local time=os.date("%X")
-- local h1,m1,s1 = string.match(time,"(%d+):(%d+):(%d+)")
-- local h2=24
-- local time1 = h1 * 3600 + m1 * 60 + s1
-- local time2 = h2 * 3600 
-- print((time2 - time1)/3600)