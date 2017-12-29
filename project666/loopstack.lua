
local historystack = {}
local NUM = 10--存的最大数
local top = -1--栈顶初始化为-1
local bottom = 0
local loopstack = {}

local fruitType = {
	"luobo",
	"baicai",
	"wandou",
	"nangua",
	"gangzhe",
	"mogu",
	"guangchangsu",
	"yidianhong",
	luobo=0,
	baicai=0,
	wandou=0,
	nangua=0,
	gangzhe=0,
	mogu=0,
	guangchangsu=0,
	yidianhong=0,
}

function historystack.push( type )
	if fruitType[type]==0 then 
		top=(top+1)%NUM
		loopstack[top]=type
		bottom=(top+1)%NUM
		-- print(top,"B",bottom)
	end
end

function historystack.getlist(  )
	local t={}
	-- print("getlist")
	local i = top+1
	while true do
		i=i-1
		if i==-1 then
			i=NUM-1
		end
		-- print("i",i)
		-- print(loopstack[i])
		if loopstack[i] then
			table.insert(t,loopstack[i])
			-- print("i,bottom",i,bottom)
			if i==bottom then
				-- print("return 1")
				return t
			end
		else
			-- print("return 2")
			return t
		end
	end
end

-- math.randomseed(os.time())
-- for i=1,100 do
	
-- 	os.execute("sleep 1s")
-- 	os.execute("clear")
-- 	historystack.push( fruitType[math.random(7)] )
-- 	local xx = historystack.getlist()
-- 	for k,v in pairs(xx) do
-- 		print(k,v)
-- 	end
-- 	print("=================")
-- end

return historystack