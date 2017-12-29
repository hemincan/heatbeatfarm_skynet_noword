
local messagespool = {maxsize=20,top=-1,pool={}}--消息池,用于存储最近10条数据
function messagespool:pushmessage( from,mess )
	self.top=(self.top+1)%self.maxsize
	self.pool[self.top]={from=from,mess=mess}
end
function messagespool:getmessagelist(  )
	local t = {}
	local bottom = (self.top+1)%self.maxsize
	local i = self.top
	while true do
		if i==bottom then
			table.insert(t,self.pool[i])
			return t
		end
		print("iiiiiiiiiiii",i)
		if self.pool[i] then
			table.insert(t,self.pool[i])
		else
			return t
		end
		i=(i-1)%self.maxsize
	end
end
messagespool:pushmessage("fsdf1","hello kugou1")
messagespool:pushmessage("fsdf2","hello kugou2")

local t = messagespool:getmessagelist()
function printtable( t ,s)
	s=s..s
	for k,v in pairs(t) do
		print(s,k,v)
		if type(v)=="table" then
			printtable(v,s)
		end
	end
end
for i=1,20 do
	os.execute("sleep 1s")
	os.execute("clear")
	messagespool:pushmessage("f"..i,"hello kugou1")
	local t = messagespool:getmessagelist()
	printtable(t,"||")
end