
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
	onlinepeople={"aaaa","bbbb","cccc","dddd"}
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
	onlinepeople={"aaaa","bbbb","cccc","dddd"}
}


function different( new,old )
	if not old then 
		old=new
		return
	end
	for k,v in pairs(new) do
		if type(v)~="table" then
			if old[k] then
				if v==old[k] then
					old[k]=nil
				else
					old[k]=v
				end
			else
				old[k]=v
			end
		else
			if #v~=0 then
				local change = false
				for i,j in pairs(new[k]) do
					if j~=old[k][i] then
						change=true
					end
				end
				if change then
					old[k]=new[k]
				else
					old[k]=nil
				end
			else
				different(new[k],old[k])
			end
		end
	end
	return new,old
end
local oldstatus,send=different(newstatus,oldstatus)

for k,v in pairs(send) do
	print(k,v)
	if type(v)=="table" then
		for i,j in pairs(v) do
			print(i,j)
		end
	end
end
print("=====================")
for k,v in pairs(oldstatus) do
	print(k,v)
	if type(v)=="table" then
		for i,j in pairs(v) do
			print(i,j)
		end
	end
end