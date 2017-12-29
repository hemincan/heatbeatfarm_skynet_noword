local fruit = {}
math.randomseed(os.time())
--Luobo baicai wandou nangua gangzhe mogu guangchangsu yidianhong
local fruitType = {
	"luobo",
	"baicai",
	"wandou",
	"nangua",
	"gangzhe",
	"mogu",
	"guangchangsu",
	"yidianhong",

}
fruitType.luobo = 1
fruitType.baicai = 2
fruitType.wandou = 3
fruitType.nangua = 4
fruitType.gangzhe = 5
fruitType.mogu = 6
fruitType.guangchangsu=7
fruitType.yidianhong=8
--中奖概率
-- local gailu = {
--  luobo = 23.94,
--  baicai = 23.93,
--  wandou = 23.75,
--  nangua = 11.88,
--  gangzhe = 7.92,
--  mogu = 3.96,
--  guangchangsu = 2.64,
--  yidianhong = 1.98,
-- }
--倍率
-- local beilu = {
--  luobo = 2,
--  baicai = 2,
--  wandou = 4,
--  nangua = 8,
--  gangzhe = 12,
--  mogu = 24,
--  guangchangsu = 36,
--  yidianhong = 48,
-- }


-- local gailu = {
--  luobo = 48.01,
--  baicai = 26.19,
--  wandou = 13.09,
--  nangua = 6.55,
--  gangzhe = 3.27,
--  mogu = 1.66,
--  guangchangsu = 0.83,
--  yidianhong = 0.40
-- }

-- local beilu = {
--  luobo = 1.2,
--  baicai = 2,
--  wandou = 4,
--  nangua = 8,
--  gangzhe = 16,
--  mogu = 24,
--  guangchangsu = 48,
--  yidianhong = 64,
-- }

-- local gailu = {
--  luobo = 43.48,
--  baicai = 23.72,
--  wandou = 11.86,
--  nangua = 5.93,
--  gangzhe = 4.74,
--  mogu = 3.95,
--  guangchangsu = 3.36,
--  yidianhong = 2.96
-- }

-- local beilu = {
--  luobo = 1.2,
--  baicai = 2,
--  wandou = 4,
--  nangua = 8,
--  gangzhe = 10,
--  mogu = 12,
--  guangchangsu = 14,
--  yidianhong = 16,
-- }
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
-- print(LUOBO)
-- print(BAICAI)
-- print(WANDOU)
-- print(NANGUA)
-- print(GANGZHE)
-- print(MOGU)
-- print(GUANGCHANGSU)
-- print(YIDIANHONG)
-- io.read()
-- -- local BAICAI = 4748
-- -- local WANDOU = 7162
-- -- local NANGUA = 8350
-- -- local GANGZHE = 9142
-- -- local MOGU = 9538
-- -- local GUANGCHANGSU = 9802
-- -- local YIDIANHONG = 10000
local ERRORCODE = require "errorcode"
local historystack = require "loopstack" --用于保存10条历史记录

local MINDEALERMONEY = 10000000
fruit.player={}
fruit.alreadyya={}
function fruit:newgame(  )--清除数据,游戏重新开始
	local t=self.alreadyya
	t.luobo=0
	t.baicai=0
	t.wandou=0
	t.nangua=0
	t.gangzhe=0
	t.mogu=0
	t.guangchangsu=0
	t.yidianhong=0

	for k,v in pairs(self.player) do
		for i,j in pairs(v) do
			if i~="money" and i~="win" and i~="currentwin" and i~="mylistnum"  then
				v[i]=0
			end
		end
	end

end
function fruit:setDealer( id )--不允许外部调用
	if not id then
		self.dealer=nil--电脑做庄家
		return true
	elseif not self.player[id] then
		--print("玩家不在房间,不能成为地主")
		return false,ERRORCODE.nopeople,id --发生错误的玩家ID
	elseif self.player[id].money<MINDEALERMONEY then
		--print("钱不够,不能成为地主")
		return false,ERRORCODE.wantdealernoenoughmoney,id
	else
		self.dealer={uniid=id,money=self.player[id].money}
		return true
	end
end
function fruit:exitDealer( id )--不允许外部调用
	if self.dealer and self.dealer.uniid==id then
		self:changeDearler( )
		return true
	else
		return false
	end
end
function fruit:getMyListNum( uniid )--返回我所在队列的是第几
	for k,v in pairs(self.list) do
		if v==uniid then
			return k
		end
	end
	if fruit:getDealerUid()==uniid then
		return -1 --是庄家显示-1
	end
	return 0--没人显示0,防止为空
end
fruit.list={}
function fruit:wantDealer( id )
	if self.dealer and self.dealer.uniid==id then
		--print("已是庄家,不要排队")

		return false,ERRORCODE.alreadyisdealer
	elseif not self.player[id] then
		--print(id)
		--print("玩家不在房间,不能上庄")
		return false,ERRORCODE.nopeople
	elseif self.player[id].money<MINDEALERMONEY then
		--print("你的钱不够")
		return false,ERRORCODE.wantdealernoenoughmoney
	else
		for k,v in pairs(self.list) do
			if v==id then
				--print("玩家已在列表")
				return false,ERRORCODE.alreadyonlist
			end
		end
		table.insert(self.list,id)
	end
	return true
end
function fruit:changeDearler(  )--到灵界值时会有一些问题未解决

	self.status.score=0
	self.status.reselect=0
	return self:setDealer(self:popDearlerList())--存在有可能失败的可能,供外部判断
end
function fruit:exitDearlerList( id )
	if not self.player[id] then
		return false,ERRORCODE.nopeople
	else
		local index = -1
		for k,v in pairs(self.list) do
			if v==id then
				index=k
				break
			end
		end
		if index==-1 then 
			--print("玩家不在队列!")
			return false,ERRORCODE.notinlist
		else
			table.remove(self.list,index)
		end
	end
	return true
end
function fruit:getDearlerList(  )
	return self.list
end

function fruit:popDearlerList(  )
	if #self.list~=0 then
		return table.remove(self.list,1)
	else
		print("队列为空")
		return nil
	end
end
function fruit:getMinMoneyDealermusthave(  )
	return MINDEALERMONEY
end
function fruit:isComputer(  )
	if self.dealer then
		return false
	end
	return true
end
function fruit:getDealer(  )
	 return self.dealer
end
function fruit:getDealerUid(  )
	if not self.dealer then 
		return ""
	else	
	    return self.dealer.uniid
	end
end
function fruit:getDealerMoney(  )
	if not self.dealer then 
		return 	tonumber(0)
	else
	    return self.dealer.money
	end
end
function fruit:getResult(  )
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
local onlinepeoplelist = {}--仅供getonlinepeople使用不可做为用户身份验证,因为在名字后面还加了头像id
local headimg = {}--用户头像
function updateonlinepeople(  )
	local tmp = {}
	for k,v in pairs(fruit.player) do
		table.insert(tmp,k.." "..headimg[k])
	end
	onlinepeoplelist=tmp
end

function fruit:getPlayer(  )--
	return onlinepeoplelist
end
function fruit:newPlayer( uniid, money ,himg)
	if self.player[uniid] then 
		--print("player alreader exit in the game!")
		return false,ERRORCODE.useralreadyexit
	end
	self.player[uniid]={}
	self.player[uniid].money=money
	self.player[uniid].luobo=0
	self.player[uniid].baicai=0
	self.player[uniid].wandou=0
	self.player[uniid].nangua=0
	self.player[uniid].gangzhe=0
	self.player[uniid].mogu=0
	self.player[uniid].guangchangsu=0
	self.player[uniid].yidianhong=0
	----
	self.player[uniid].currentwin=0
	self.player[uniid].win=0
	self.player[uniid].mylistnum=0

	headimg[uniid]=himg
	updateonlinepeople(  )--onlinepeople改变才重新获取新的值
	return true
end
function fruit:playerExit( uniid )
	--如果玩家在庄家排队的队列中,将其从队列移除
	fruit:exitDearlerList( uniid )
	--print("------sadfasdfasdfasdfasdf",uniid)
	self.player[uniid]=nil
	headimg[uniid]=nil
	if self.dealer and self.dealer.uniid==uniid then--如果玩家是dealer的话,把它退出
		self.dealer=nil
		-- self:setDealer(self:popDearlerList())--队列玩家做庄家
		--注释原因,不共同使用changedealer,以至连任没更新
		fruit:changeDearler( )
	end
	updateonlinepeople(  )--onlinepeople改变才重新获取新的值
	
end
function fruit:getPlayerCount(  )
	-- local count = 0
	-- for k,v in pairs(self.player) do
	-- 	count=count+1
	-- end
	return #onlinepeoplelist
end
------------------
function fruit:ya( uniid,type,money )
	--print("userid",self:getDealerUid())
	if money<0 or not fruitType[type] then--不合法的钱的,水果类型 
		return false,ERRORCODE.moneyandtype
	elseif not self.player[uniid] then
		--print("此人不存在")
		return false,ERRORCODE.nopeople
	elseif self:getDealerUid()==uniid then
		--print("地主不要压")
		return false,ERRORCODE.dealerya
	end
	type=fruitType[type]
	---注释原因,因可以压不止一次,可多次压注,只要总压注金额不超过可赔
	-- if self.player[uniid][type]~=0 then
	-- 	print("你已经压过",type)
	-- 	return false,ERRORCODE.havedya
	-- end


	--print("aaaaaaa",self.player[uniid][type],type)
	if self.player[uniid].money<money then--压的人钱已经不够
		--print("you havent so many money!")
		return false,ERRORCODE.yanoenoughmoney
	end
	local playercount = self:getPlayerCount()-1--减不包括庄家
	--print("此处上限",playercount,beilu[type],(self:getDealerMoney()/playercount)/beilu[type],money)
	-- 原先 if (self:getDealerMoney()/playercount)/beilu[type] >= money then 
	if self:isComputer() then
		--电脑做庄不用计算上限
		self.player[uniid][type]=money+self.player[uniid][type]
		self.alreadyya[type]=self.alreadyya[type]+money
		self.player[uniid].money=self.player[uniid].money-money
		return true

	elseif (self:getDealerMoney()/playercount)/beilu[type] >= self.player[uniid][type]+money then 
		self.player[uniid][type]=money+self.player[uniid][type]
		self.alreadyya[type]=self.alreadyya[type]+money
		self.player[uniid].money=self.player[uniid].money-money

		return true
	else
		--压钱超庄家可赔上限
		--print("压钱超庄家可赔上限!",(self:getDealerMoney()/playercount)/beilu[type])
		return false,ERRORCODE.uppermoneylimit         
	end
end
function fruit:yaLouBo( uniid,money )
	return self:ya(uniid,fruitType.luobo,money)
end
function fruit:yaBaiCai( uniid,money )
	return self:ya(uniid,fruitType.baicai,money)
end
function fruit:yaWanDou( uniid,money )
	return self:ya(uniid,fruitType.wandou,money)
end
function fruit:yaNanGua( uniid,money )
	return self:ya(uniid,fruitType.nangua,money)
end
function fruit:yaGangZhe( uniid,money )
	return self:ya(uniid,fruitType.gangzhe,money)
end
function fruit:yaMoGu( uniid,money )
	return self:ya(uniid,fruitType.mogu,money)
end
function fruit:yaGuangChangSu( uniid,money )
	return self:ya(uniid,fruitType.guangchangsu,money)
end
function fruit:yaYiDianHong( uniid,money )
	return self:ya(uniid,fruitType.yidianhong,money)
end
function fruit:syncDealerMoney(  )--sync Dealer Money in Player[uniid]
	if self.dealer then--如果此玩家是地主,将它的钱同步起来
		local uniid = self.dealer.uniid
		self.player[uniid].money=self.dealer.money
		self.player[uniid].currentwin=self.status.score
		self.player[uniid].win=self.player[uniid].currentwin+self.player[uniid].win
		self.status.score=0--score 是一局的分数,
	end
end
function fruit:getPlayerStatus( uniid )
	local tmp = {}
	for k,v in pairs(self.player[uniid]) do
		tmp[k]=v
	end
	tmp.mylistnum=self:getMyListNum( uniid )--获得自己的排队队列
	return tmp
end
function fruit:getHistoryList(  )
	return historystack.getlist()
end
function fruit:getPlayerMoney( uniid )
	return self.player[uniid].money
end
function fruit:getPlayerWin( uniid )
	return self.player[uniid].win
end
function fruit:getPlayerCurrentWin( uniid )
	return self.player[uniid].currentwin
end
function fruit:getOnlinePeople(  )
	return self:getPlayer()
end
function fruit:getReslectCount(  )
	return self.status.reselect
end
fruit.status={score=0,reselect=0}
function fruit:getGameStatus(  )
	self.status.dealer=self:getDealerUid()
	self.status.dealermoney=self:getDealerMoney()
	-- self.status.score=0--暂定
	-- self.status.reselect=0--暂定
	local t=self.alreadyya
	self.status.luobo=t.luobo
	self.status.baicai=t.baicai
	self.status.wandou=t.wandou
	self.status.nangua=t.nangua
	self.status.gangzhe=t.gangzhe
	self.status.mogu=t.mogu
	self.status.guangchangsu=t.guangchangsu
	self.status.yidianhong=t.yidianhong
	--更改原因,waitinglist不需要是个数组,只是一个数字
	-- self.status.waitinglist=self:getDearlerList()
	self.status.waitinglist=#self:getDearlerList()
	--注释原因,Onlinepeople不再需要放在游戏状态上
	-- self.status.onlinepeople=self:getPlayer()--在线的用户,包括自己---目前用做调试用,onlinepeople不加入gamestatus
	local tmp = {}
	for k,v in pairs(self.status) do
		tmp[k]=v
	end
	if self.dealer then
		tmp.score=self.player[self:getDealerUid()].currentwin
	end
	return tmp
end
fruit.resulttable={}
function fruit:open(  )
	local result,index = self:getResult()
	--把历史记录放到栈中
	historystack.push(result)
	self.resulttable.result=result
	self.resulttable.index=index
	-- print("----------------------result",result,index)
	self.status.reselect=self.status.reselect+1
	--结算放在其他位置
	local resulttmp = {}
	resulttmp.result=self.resulttable.result
	resulttmp.index=self.resulttable.index
	return resulttmp
end
function fruit:settleAccounts(  )--结算这一局的结果
		local dealer = self:getDealer()
		for k,v in pairs(self.player) do--遍历玩家table,把不是中奖的钱全部收为自己所有
			v.currentwin=0--当前局的状态先置0
			for i,j in pairs(v) do
				--扩展性不是很好的If语句
				if i~="money" and i~="win" and i~="currentwin" and i~="mylistnum"  then
					if i~= self.resulttable.result then
						if dealer then
							dealer.money = dealer.money + j
						     --庄家需要知道他的分数
							self.status.score = self.status.score + j
						end
						     --记录玩家当前局所得,负就是失去
						v.currentwin=v.currentwin-j
						
					else
						if dealer then
						--print("beilu[i]*j",beilu[i]*j)
						--庄家需要知道他的分数
							self.status.score = self.status.score - beilu[i]*j
							dealer.money = dealer.money - beilu[i]*j
						     -- v.money=v.money+beilu[i]*j+j----本钱还
						end
						v.money=v.money+beilu[i]*j--本钱不还,庄家赔相应倍率,本钱系统收取
						v.currentwin=v.currentwin+beilu[i]*j-j--算上自己压的钱,其实只羸了倍率减一的钱
						
					end
					
				end
			end
			v.win=v.win+v.currentwin
			
		end
	self:syncDealerMoney(  )--syncDealerMoney in Player[uniid]
end
return fruit