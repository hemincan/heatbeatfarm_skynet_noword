local gailu = {
 luobo = 25.14,
 baicai = 19.02,
 wandou = 15.01,
 nangua = 11.68,
 gangzhe = 9.41,
 mogu = 7.76,
 guangchangsu = 6.38,
 yidianhong = 5.6
}

local beilu = {
 luobo = 2,
 baicai = 4,
 wandou = 6,
 nangua = 8,
 gangzhe = 10,
 mogu = 12,
 guangchangsu = 14,
 yidianhong = 16,
}

local LUOBO = 0 + gailu.luobo*100
local BAICAI = LUOBO + gailu.baicai*100
local WANDOU = BAICAI + gailu.wandou*100
local NANGUA = WANDOU + gailu.nangua*100
local GANGZHE = NANGUA + gailu.gangzhe*100
local MOGU = GANGZHE + gailu.mogu*100
local GUANGCHANGSU = MOGU + gailu.guangchangsu*100
local YIDIANHONG = GUANGCHANGSU + gailu.yidianhong*100
-- math.randomseed(os.time())
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



-- local MYYAMONEY = 1000
-- local mymoney = 200000000
-- local myya =MYYAMONEY
-- local testresult = "luobo"
-- for i=1,1000 do
-- 	local result = getResult()
-- 	print("mymoney",mymoney,"myya",myya,result)
-- 	if result==testresult then
-- 		mymoney=mymoney+myya*beilu[testresult]
-- 		myya=MYYAMONEY
-- 	else
-- 		myya=myya*2
-- 		-- if myya>10000000 then
-- 		-- 	print("------------")
-- 		-- 	print("tobig",mymoney,myya)
-- 		-- 	print("------------")
-- 		-- 	myya=myya/2
-- 		-- end
-- 		-- if myya>mymoney then
-- 		-- 	myya=0
-- 		-- else
-- 			mymoney=mymoney-myya
-- 		-- end

-- 	end
-- 	if mymoney<0 then
-- 		print("mymoney end",i)
-- 		break
-- 	end
-- end

