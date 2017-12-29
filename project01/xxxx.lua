


-- if t.dealer then
-- --更新庄家姓名
-- end
-- if t.dealermoney then
-- --更新庄家钱
-- end
-- if t.score then
-- --更新庄家分数
-- end
-- if t.reselect then
-- --连任次数
-- end
-- if t.luobo then
-- --罗bo所压钱
-- end
-- if t.baicai then
-- --白菜所压钱
-- end
-- if t.wandou then
-- --豌豆
-- end
-- if t.nangua then
-- --南瓜
-- end
-- if t.gangzhe then
-- --甘蔗
-- end
-- if t.mogu then
-- --蘑菇
-- end
-- if t.guangchangsu then
-- --关唱树
-- end
-- if t.yidianhong then
-- --一点红
-- end
-- if t.waitinglist then--等待列表数组,1234按顺序做Key,值是用户id

-- end
-- if t.onlinepeople then--数组,在线的游戏玩家,包括自己

-- end

-- if t.mystatus then--我的状态列表
-- 	local mystat = t.mystatus
-- 	if mystat.currentwin then
-- 		--当局所赢钱
-- 	end
-- 	if mystat.win then
-- 		--进入房间以来赢的钱
-- 	end
-- 	if mystat.money then
-- 		--我的鱼额
-- 	end
-- 	if mystat.mylistnum then
-- 		--我的排队名次
-- 	end
-- 	if mystat.luobo then
-- 		--我压萝卜的金额
-- 	end
-- 	if mystat.baicai then
-- 		--我压白菜的金额
-- 	end
-- 	if mystat.wandou then
-- 		--我压豌豆的金额
-- 	end
-- 	if mystat.nangua then
-- 		--我压南瓜的金额
-- 	end
-- 	if mystat.gangzhe then
-- 		--我压甘蔗的金额
-- 	end
-- 	if mystat.mogu then
-- 		--我压蘑菇的金额
-- 	end
-- 	if mystat.guangchangsu then
-- 		--我压关仓术的金额
-- 	end
-- 	if mystat.yidianhong then
-- 		--我压一点红的金额
-- 	end

-- end

local proto = {
    gamestatus = {
		"dealer",
		"dealermoney",
		"score",
		"reselect",
		"luobo",
		"baicai",
		"wandou",
		"nangua",
		"gangzhe",
		"mogu",
		"guangchangsu",
		"yidianhong",
		"waitinglist",
		"mystatus",
		"onlinepeople",
		waitinglist={},
		onlinepeople={},
		mystatus={
			  "money",
		      "luobo",
		      "baicai",
		      "wandou",
		      "nangua",
		      "gangzhe",
		      "mogu",
		      "guangchangsu",
		      "yidianhong",
		      "currentwin",
		      "win",
		}
	},
	hello={
		"name",
		"age",
	}

}


function encode( t )
	if not t.action then
		return nil
	end
	local encodet = proto[t.action]
	if not encodet then
		print("no such action")
		local resever = {}
		for i,v in ipairs(encodet) do
			resever[v]=i
		end
		for k,v in pairs(t) do
			local x = resever[k]
			t[x]=v
			t[k]=nil
		end
		return resever
	end
end

local xx={action="hello",name="hemincan",age=12}
xx=encode(xx)

for k,v in pairs(xx) do
	print(k,v)
end
