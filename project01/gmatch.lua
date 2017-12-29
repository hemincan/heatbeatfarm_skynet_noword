local x = "sdkfsldkjfls...jdfa\naskdjflskadghlsakdjflk\nsgsdfsdglkf\n"

local t ={}
for v in string.gmatch(x,"(.-)\n") do
	table.insert(t,v)
end

for k,v in ipairs(t) do
	print(k,v)
end
math.randomseed(os.time())
local gailu = {
 luobo = 23.94,
 baicai = 23.93,
 wandou = 23.75,
 nangua = 11.88,
 gangzhe = 7.92,
 mogu = 3.96,
 guangchangsu = 2.64,
 yidianhong = 1.98,
}
local LUOBO = 0 + gailu.luobo*100
local BAICAI = LUOBO + gailu.baicai*100
local WANDOU = BAICAI + gailu.wandou*100
local NANGUA = WANDOU + gailu.nangua*100
local GANGZHE = NANGUA + gailu.gangzhe*100
local MOGU = GANGZHE + gailu.mogu*100
local GUANGCHANGSU = MOGU + gailu.guangchangsu*100
local YIDIANHONG = GUANGCHANGSU + gailu.yidianhong*100
function getResult(  )
	local x = math.random(10000)
	local index = math.random(0,2)
	if x>=1 and x<=LUOBO then--萝卜
		return "luobo",index
	elseif x>LUOBO and x<=BAICAI then--白菜
		return "baicai",index
	elseif x>BAICAI and x<=WANDOU then--豌豆
		return "wandou",index
	elseif x>WANDOU and x<=NANGUA then--南瓜
		return "nangua",index
	elseif x>NANGUA and x<=GANGZHE then --甘蔗
		return "gangzhe",index
	elseif x>GANGZHE and x<=MOGU then --蘑菇
		return "mogu",index
	elseif x>MOGU and x<= GUANGCHANGSU then --关仓术
		return "guangchangsu",index
	elseif x>GUANGCHANGSU and x<=YIDIANHONG then--一点红
		return "yidianhong",index
	end
end
local t = {}
local count=50
for i=1,count do
	local x = getResult()
	if t[x] then
		t[x]=t[x]+1
	else
		t[x]=1
	end
end

for k,v in pairs(t) do
	print(k,v)
end