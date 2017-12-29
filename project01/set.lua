
local oldstatus={
	action="gamestatus",
	dealer="aaaa",
	dealermoney=15245,
	score=0,
	reselect=1,
	luobo=21000,
	baicai=0,
	wandou=0,
	nangua=0,
	gangzhe=0,
	mogu=0,
	guangchangsu=0,
	yidianhong=0,
	waitinglist={"aaaa","bbbb","cccc","dddd"},
	mystatus={
	      money=54221,
	      luobo=0,
	      baicai=123,
	      wandou=0,
	      nangua=0,
	      gangzhe=1000,
	      mogu=0,
	      guangchangsu=0,
	      yidianhong=0,
	      currentwin=0,
	      win=0,
	},
	onlinepeople={}
}

local newstatus={
	action="gamestatus",
	dealer="aaaa2",
	dealermoney=15245,
	score=0,
	reselect=0,
	luobo=21000,
	baicai=0,
	wandou=0,
	nangua=200,
	gangzhe=444,
	mogu=122222,
	guangchangsu=12222,
	yidianhong=200,
	waitinglist={"aaaa","bbbb","cccc","dddd","ff"},
	mystatus={
	      money=54221,
	      luobo=0,
	      baicai=123,
	      wandou=0,
	      nangua=0,
	      gangzhe=1000,
	      mogu=0,
	      guangchangsu=0,
	      yidianhong=0,
	      currentwin=0,
	      win=0,
	},
	onlinepeople={"aaaa","bbbb","cccc","dddd"}
}


-- function different( new,old )
-- 	if not old then 
-- 		old=new
-- 		return
-- 	end
-- 	for k,v in pairs(new) do
-- 		if type(v)~="table" then
-- 			if old[k] then
-- 				if v==old[k] then
-- 					old[k]=nil
-- 				else
-- 					old[k]=v
-- 				end
-- 			else
-- 				old[k]=v
-- 			end
-- 		else
-- 			if #v~=0 then
-- 				local change = false
-- 				for i,j in pairs(new[k]) do
-- 					if j~=old[k][i] then
-- 						change=true
-- 					end
-- 				end
-- 				if change then
-- 					old[k]=new[k]
-- 				else
-- 					old[k]=nil
-- 				end
-- 			else
-- 				different(new[k],old[k])
-- 			end
-- 		end
-- 	end
-- 	return new,old
-- end
-- local oldstatus,send=different(newstatus,oldstatus)

-- for k,v in pairs(send) do
-- 	print(k,v)
-- 	if type(v)=="table" then
-- 		for i,j in pairs(v) do
-- 			print(i,j)
-- 		end
-- 	end
-- end
-- print("=====================")
-- for k,v in pairs(oldstatus) do
-- 	print(k,v)
-- 	if type(v)=="table" then
-- 		for i,j in pairs(v) do
-- 			print(i,j)
-- 		end
-- 	end
-- end

local pack = require "pack"
-- print(send)
-- send.action="gamestatus"
local en = pack.encode(oldstatus)
print(en)
-- print(pack.encode(oldstatus))
-- oldstatus.action="gamestatus"
-- local x = pack.decode(pack.encode(oldstatus))

local x = pack.decode(en)
printtable(x,"^^")





-- local xxx={action="hello",a=1,b=2,c=3,d=4}

-- local test ={
-- 		action="gamestatus",
-- 		dealer="dealer",
-- 		dealermoney=50000,
-- 		score=500,
-- 		reselect=2,
-- 		luobo=200,
-- 		baicai=0,
-- 		wandou=0,
-- 		session=111111,
-- 		nangua=0,
-- 		gangzhe=0,
-- 		mogu=0,
-- 		guangchangsu=0,
-- 		yidianhong=0,
-- 		waitinglist={"aa","bb"},
-- 		onlinepeople={"aa","bb","cc"},
-- 		mystatus={
-- 			  money=50000,
-- 		      luobo=200,
-- 		      baicai=100,
-- 		      wandou=0,
-- 		      nangua=0,
-- 		      gangzhe=0,
-- 		      mogu=0,
-- 		      guangchangsu=0,
-- 		      yidianhong=0,
-- 		      currentwin=0,
-- 		      win=200,
-- 		},
-- }

-- local newtable = pack.encode( {action="wantdealer"} )
-- print(newtable)
-- -- printtable(newtable,"--")
-- print("========ss===s==")
-- table=pack.decode(newtable)
-- printtable(table,"--")
