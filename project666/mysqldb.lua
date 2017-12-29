local skynet = require "skynet"
local mysql = require "mysql"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
require "skynet.manager"

local CMD = {}
local db 

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end





--修改信息
function CMD.SELECTNAME(msg)--查询用户名，msg.username
	local res = db:query("select username from user where binary username='" .. msg.username .. "'")
	print(dump(res))
	local x
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	if x == msg.username then
		return true
	else
		return false
	end
end

function CMD.UPDATENAME(msg)--修改用户名
	local res = db:query("update user set username='" .. msg.newusername .. "' where binary username='" .. msg.username .. "'")
	res = db:query("update property set username='" .. msg.newusername .. "' where binary username='" .. msg.username .. "'")
	res = db:query("select username from user where binary username ='" .. msg.newusername .. "'")
	local x 
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	if x == msg.newusername then
		return true
	else
		return false
	end
end

function CMD.UPDATEPW(msg)--修改密码
	local res = db:query("update user set upassword='" .. msg.newupassword .. "' where uid='" .. msg.uid .. "' and upassword='" .. msg.upassword .. "'")
	res = db:query("select upassword from user where uid ='" .. msg.uid .. "'")
	local x
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	if x == msg.newupassword then
		return true --密码正确
	else
		return false
	end
end

function CMD.UPDATEBPW(msg)--修改银行密码
	local res = db:query("update user set bpassword='" .. msg.newbpassword .. "' where uid='" .. msg.uid .. "' and bpassword='" .. msg.bpassword .. "'")
	print(dump(res))
	res = db:query("select bpassword from user where uid ='" .. msg.uid .. "'")
	local x
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	if x == msg.newbpassword then
		return true --密码正确
	else
		return false
	end
end





--注册登录

function CMD.REGISTER(msg)--注册, 传入msg.uaccount, msg.upassword, msg.username
	local res = db:query("insert into user(uaccount, upassword, username)" .. 
				"values('" .. msg.uaccount .. "','" .. msg.upassword .. "','" .. msg.username .. "')")
	print(dump(res)) 
		
	res = db:query("insert into property(uaccount, username)" ..
			"values('" .. msg.uaccount .. "','" .. msg.username .. "')")
	return "register success"
end

function CMD.VISITOR(msg)--游客，传入msg.uaccount, msg.username, msg.vid
	local res = db:query("insert into user(uaccount, upassword, username, vid)" .. 
				"values('" .. msg.uaccount .. "','" .. msg.upassword .. "','" .. msg.username .. "','" .. msg.vid .. "')") 
		
	res = db:query("insert into property(uaccount, username)" ..
				"values('" .. msg.uaccount .. "','" .. msg.username .. "')")
	return true
end

function CMD.SETVID(msg)--查询游客ID记录，返回当前最大ID数
	local x 
	local res = db:query("select vid from user order by vid desc limit 0,1")
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	return x
end

function CMD.SELECT(msg)--返回用户基本信息, 传入msg.uaccount
	local x = {}
	local res = db:query("select u.uid, u.uaccount, u.upassword, u.username, u.enable, u.bpassword, u.portrait, p.cash, p.deposit " ..
	"from user as u, property as p where binary u.uaccount='" .. msg.uaccount .."'" ..
    "and binary p.uaccount='" .. msg.uaccount .. "'")
    for k,v in pairs(res) do
    	for i,j in pairs(v) do
    		x = v
    	end
    end 
    return x
end

function CMD.SELECTVALI(msg)--查询是否已有用户名和账号,msg.uaccount
	local res = db:query("select uaccount from user where binary uaccount='" .. msg.uaccount .. "'")
	local x 
	local y
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	res = db:query("select username from user where binary username='" .. msg.uaccount .. "'")
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			y = j
		end
	end
	if x == msg.uaccount or y == msg.uaccount then
		return true--已存在，不可注册
	else 
		return false
	end
end

function CMD.VALINAME(msg)--验证是否存在用户名 msg.username
	local res = db:query("select username from user where binary username ='" .. msg.username .. "'")
	for k,v in pairs(res) do
		if v then
			return true --存在
		else
		return false
		end
	end
end 

function CMD.VALIACC(msg)--验证是否存在用户账号 msg.uaccount
	local res = db:query("select uaccount from user where binary uaccount ='" .. msg.uaccount .. "'")
	for k,v in pairs(res) do
		if v then
			return true --存在
		else
		return false
		end
	end
end

function CMD.VALIDATE(msg)--验证能否注册，能返回true，不能返回false
	local x = CMD.VALIACC(msg)
	local y = CMD.VALINAME(msg)
	if x or y then
		return false
	else
		return true
	end
end

function CMD.LOGINVALI(msg)--登录验证
	local res = db:query("select upassword from user where binary uaccount ='" .. msg.uaccount .. "'")
	local x 
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	if x == msg.upassword then
		return true --密码正确
	else
		return false
	end
end

function CMD.INTIPOR(msg)--更改头像，msg.portrait,msg.uaccount
	local res = db:query("update user set portrait='" .. msg.portrait .. "' where binary uaccount='" .. msg.uaccount .. "'")
end




--金币，银行

function CMD.UPDATECASH(msg)--根据账号更新现金, 传入msg.uaccount, msg.cash
	local res = db:query("update property set cash=(cash+'" .. msg.cash .. "') where binary uaccount='" .. msg.uaccount .. "'")
	return true
end

function CMD.UPDATECASHBYNAME(msg)--根据用户名更新现金, 传入msg.username, msg.cash
	local res = db:query("update property set cash=(cash+'" .. msg.cash .. "') where binary username='" .. msg.username .. "'")
	return true
end

function CMD.SAVEDEPOSIT(msg)--根据账号存钱, 传入msg.uaccount, msg.deposit
	local res = db:query("update property set deposit=(deposit+'" .. msg.deposit ..
	 "'), cash=(cash-'" .. msg.deposit .. "') where binary uaccount='" .. msg.uaccount .. "'")
	print(dump(res))
	return true
end

function CMD.TAKEDEPOSIT(msg)--根据账号取钱, 传入msg.uaccount, msg.deposit
	local res = db:query("update property set deposit=(deposit-'" .. msg.deposit ..
	 "'), cash=(cash+'" .. msg.deposit .. "') where binary uaccount='" .. msg.uaccount .. "'")
	print(dump(res))
	return true
end

function CMD.SAVEDEPOSITBYNAME(msg)--根据用户名存钱, 传入msg.username, msg.deposit
	local res = db:query("update property set deposit=(deposit+'" .. msg.deposit ..
	 "'), cash=(cash-'" .. msg.deposit .. "') where binary username='" .. msg.username .. "'")
	print(dump(res))
	return true
end

function CMD.TAKEDEPOSITBYNAME(msg)--根据用户名取钱, 传入msg.username, msg.deposit
	local res = db:query("update property set deposit=(deposit-'" .. msg.deposit ..
	 "'), cash=(cash+'" .. msg.deposit .. "') where binary username='" .. msg.username .. "'")
	print(dump(res))
	return true
end

function CMD.SELECTCASH(msg)--根据账号查询现金， 传入msg.uaccount
	local res = db:query("select cash from property where binary uaccount='" .. msg.uaccount .. "'")
	local x = {}
	for k,v in pairs(res) do
    	for i,j in pairs(v) do
    		x = v
    	end
    end 
    return x
end

function CMD.SELECTDEPOSIT(msg)--根据账号查询银行， 传入msg.uaccount
	local res = db:query("select deposit from property where binary uaccount='" .. msg.uaccount .. "'")
	local x = {}
	for k,v in pairs(res) do
    	for i,j in pairs(v) do
    		x = v
    	end
    end 
    return x
end

function CMD.SELECTCASHBYNAME(msg)
	local res = db:query("select cash from property where binary username='" .. msg.username .. "'")
	local x = {}
	for k,v in pairs(res) do
    	for i,j in pairs(v) do
    		x = v
    	end
    end 
    return x
end

function CMD.SELECTMONEYBYNAME(msg)--银行查询，msg.username
	local res = db:query("select cash, deposit from property where binary username='" .. msg.username .. "'")
	return res
end






--充值

function CMD.SAVEBUY(msg)--保存充值信息, 传入msg.uid, msg.uaccount, msg.username, msg.price, msg.notifytime, msg.state 
	local res = db:query("insert into shop(uid, uaccount, username, price, notifytime, state)" .. 
		"values('" .. msg.uid .. "','" .. msg.uaccount .. "','" .. msg.username .. "','" .. msg.price ..
		"', now(), 1)")
	print(dump(res))
	return true
end
	
function CMD.BUY(msg)--充值成功,传入msg.price， msg.uaccount
	local x = msg.price
	x = tonumber(x)
	if x == 2 then		
		res = db:query("update property set cash=(cash+50000) where binary uaccount='" .. msg.uaccount .. "'")
	elseif x == 4 then		
		res = db:query("update property set cash=(cash+100000) where binary uaccount='" .. msg.uaccount .. "'")
	elseif x == 39.8 then
		res = db:query("update property set cash=(cash+1000000) where binary uaccount='" .. msg.uaccount .. "'")
	elseif x == 388 then
		res = db:query("update property set cash=(cash+10000000) where binary uaccount='" .. msg.uaccount .. "'")
	end
	return true
end



--排行榜

function CMD.SELECTRANKTOTAL(msg)--查询总排行榜
	local res = db:query("select username, (cash+deposit) from property order by (cash+deposit) desc limit 0,10")
	for k,v in pairs(res) do
		if type(v)=="table" then
			local tmp = {}
			for i,j in pairs(v) do
				table.insert(tmp,j)
			end
			res[k]=tmp
		end
	end
    return res
end

function CMD.INTRANK(msg)--初始化每日排行榜， 传入msg.username，msg.cash
	local res = db:query("select * from ranking where binary username='" .. msg.username .. "' and date=(select curdate())")
	local x = 0
	for k,v in pairs(res) do
		if v then
			x = 1
		end
	end	
	if x == 0 then
		res = db:query("insert ranking(date, username, gains, time) values(curdate(), '" ..  msg.username .. "', 0, now())")
		print(dump(res))
	end
end

function CMD.UPDATERANK(msg)--更新排行榜，msg.gains,msg.time,msg.username
	local res = db:query("update ranking set gains=gains+'" .. msg.cash .. "', time=(select now()) where binary username='" .. msg.username .. "' and date=(select curdate())")
	print(res.affected_rows)
	if res.affected_rows == 0 then
		res = db:query("insert ranking(date, username, gains, time) values(curdate(), '" ..  msg.username .. "', 0, now())")
		print(dump(res))
		db:query("update ranking set gains=gains+'" .. msg.cash .. "', time=(select now()) where binary username='" .. msg.username .. "' and date=(select curdate())")
	end
	return true
end

function CMD.SELECTRANKDAILY(msg)--查询日排行榜, msg.date
	local res = db:query("select username, gains from ranking where date=(select curdate()) order by gains desc, time limit 0,10")
	print(dump(res))
	for k,v in pairs(res) do
		if type(v)=="table" then
			local tmp = {}
			for i,j in pairs(v) do
				table.insert(tmp,j)
			end
			res[k]=tmp
		end
	end
	return res
end





--在线奖励

function CMD.SAVEONLINE(msg)--保存当日在线奖励, msg.uid, msg.uaccount, msg.username
	local res = db:query("update online set onlineTime='" .. msg.onlineTime .. "' where uid='" .. msg.uid .. "' and day=(select curdate())")
	if res.affected_rows == 0 then
		res = db:query("insert online(day, uid, uaccount, username, onlineTime)" .. 
		"values(curdate(),'" .. msg.uid .. "','" .. msg.uaccount .. "','" .. msg.username .. "', 0)")
		db:query("update online set onlineTime='" .. msg.onlineTime .. "' where uid='" .. msg.uid .. "' and day=(select curdate())")
	end
	return true
end

function CMD.SAVEYESTERDAY(msg)--保存昨天的在线奖励, msg.uid, msg.uaccount, msg.username,msg.onlineTime

	local res = db:query("update online set onlineTime='" .. msg.onlineTime .. "' where uid='" .. msg.uid .. "' and day=(date_sub(curdate(),interval 1 day))")
	print(dump(res))
	return true
end

function CMD.SELECTTIME(msg)--查询用户当日在线时长，msg.uid
	local res = db:query("select onlineTime from online where uid='" .. msg.uid .. "' and day=(select curdate())")
	print(dump(res))
	local x 
	for k,v in pairs(res) do
		x = v
	end
	return x
end

function CMD.UPDATESTAGE1(msg)--在线时长达到30分钟,msg.uid
	local res = db:query("update online set stage1=1 where uid='" .. msg.uid .. "' and day=(select curdate())")
	return true
end

function CMD.UPDATESTAGE2(msg)--在线时长达到1小时,msg.uid
	local res = db:query("update online set stage2=1 where uid='" .. msg.uid .. "' and day=(select curdate())")
	return true
end

function CMD.UPDATESTAGE3(msg)--在线时长达到3小时,msg.uid
	local res = db:query("update online set stage3=1 where uid='" .. msg.uid .. "' and day=(select curdate())")
	return true
end

function CMD.UPDATESTAGE4(msg)--在线时长达到5小时,msg.uid
	local res = db:query("update online set stage4=1 where uid='" .. msg.uid .. "' and day=(select curdate())")
	return true
end

function CMD.SELECTSTAGE(msg)--查询在线奖励，msg.uid, msg.uaccount, msg.username
	local res = db:query("select stage1, stage2, stage3, stage4, onlineTime from online where uid='" .. msg.uid .. "' and day=(select curdate())")
	local y = 0
	for k,v in pairs(res) do
		if v then
			y = 1
		end
	end	
	if y == 0 then
		db:query("insert online(day, uid, uaccount, username, onlineTime)" .. 
		"values(curdate(),'" .. msg.uid .. "','" .. msg.uaccount .. "','" .. msg.username .. "', 0)")
	end
	res = db:query("select stage1, stage2, stage3, stage4, onlineTime from online where uid='" .. msg.uid .. "' and day=(select curdate())")
	local x = {}
	for k,v in pairs(res) do
  		x = v
    end 
    return x
end

function CMD.RESETSTAGE(msg)--置0，msg.uid
	local res = db:query("update online set stage1=0, stage2=0, stage3=0, stage4=0, onlineTime=0 where uid='" .. msg.uid .. "' and day=(select curdate())")
end

function CMD.GETREWARD1(msg)--领取30分钟在线奖励，msg.username
	local res = db:query("update property set cash=cash+5000 where binary username='" .. msg.username .. "'" )
	res = db:query("update online set stage1=2 where binary username='" .. msg.username .. "' and day=(select curdate())")
	return true
end

function CMD.GETREWARD2(msg)--领取一小时在线奖励，msg.username
	local res = db:query("update property set cash=cash+15000 where binary username='" .. msg.username .. "'" )
	res = db:query("update online set stage2=2 where binary username='" .. msg.username .. "' and day=(select curdate())")
	return true
end

function CMD.GETREWARD3(msg)--领取三小时在线奖励，msg.username
	local res = db:query("update property set cash=cash+50000 where binary username='" .. msg.username .. "'" )
	res = db:query("update online set stage3=2 where binary username='" .. msg.username .. "' and day=(select curdate())")
	return true
end

function CMD.GETREWARD4(msg)--领取五小时在线奖励，msg.username
	local res = db:query("update property set cash=cash+100000 where binary username='" .. msg.username .. "'" )
	res = db:query("update online set stage4=2 where binary username='" .. msg.username .. "' and day=(select curdate())")
	return true
end

--救济金

function CMD.GETALMS(msg)--领取救济金,msg.uaccount
	local res = db:query("update property set cash=(cash+20000) where binary uaccount='" .. msg.uaccount .. "'")
	res = db:query("update online set stage5=2 where binary uaccount='" .. msg.uaccount .. "' and day=(select curdate())")
	return 2 --已领取，返回2
end

function CMD.SELECTSTAGE5(msg)--查询领取状态,msg.uaccount
	local res = db:query("select stage5 from online where binary uaccount='" .. msg.uaccount .. "' and day=(select curdate())")
	local x 
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	x = tonumber(x)
	return x--0不可领取，1可领取，2已领取
end

function CMD.SELECTALMS(msg)--查询是否符合救济金,msg.uaccount
	local res = db:query("select (cash+deposit) from property where binary uaccount='" .. msg.uaccount .. "'")
	print(dump(res))
	local x 
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			x = j
		end
	end
	x = tonumber(x)
	if x < 5000 then
		res = db:query("update online set stage5=1 where binary uaccount='" .. msg.uaccount .. "' and day=(select curdate()) and stage5!=2")
		return 1 --可领取，返回1
	else
		res = db:query("update online set stage5=0 where binary uaccount='" .. msg.uaccount .. "' and day=(select curdate()) and stage5!=2")
		return 0 --不可领取，返回0
	end
end



--记录

function CMD.SAVERECORD(msg)
	local res = db:query("select * from Receive_record where code='" .. msg.code .. "' and uid='" .. msg.uid .. "'")
	local x = 1
	for k,v in pairs(res) do
		if v then
			x = 0
		end
	end
	if x == 1 then
		res = db:query("insert Receive_record(uid, uaccount, username, code, time)" .. 
			"values('" .. msg.uid .. "','" .. msg.uaccount .. "','" .. msg.username .. "','" .. msg.code ..
			"', now())")
		print(dump(res))
	end
	
end

function CMD.SELECTRECORD(msg)
	local res = db:query("select * from record where uid='" .. msg.uid .. "' order by rtime desc limit 0,10")
	print(dump(res))
	for k,v in pairs(res) do
		print(k,v)
	end
	return res
end

function DBCONNET()--连接数据库
	local function set_charset(db)
		db:query("set charset utf8")
	end
	db = mysql.connect({
		host="59.110.139.75",--192.168.80.163,59.110.139.75,60.205.179.119
		port=3306,
		database="xtnc",
		user="root",
		password="81194324",
		max_packet_size = 1024 * 1024,
		on_connect = set_charset
	})
	if not db then
		skynet.error("failed to connect")
	else
		skynet.error("success to connect to mysql server\n")	    
	end
end

-- function DBCONNET()--连接数据库
	-- local function set_charset(db)
-- 		db:query("set charset utf8")
-- 	end
-- 	db = mysql.connect({
-- 		host="192.168.80.163",--192.168.80.163,59.110.139.75
-- 		port=3306,
-- 		database="xtnc",
-- 		user="root",
-- 		password="19950823",
-- 		max_packet_size = 1024 * 1024,
-- 		on_connect = set_charset
-- 	})
-- 	if not db then
-- 		skynet.error("failed to connect")
-- 	else
-- 		skynet.error("success to connect to mysql server\n")	    
-- 	end
-- end


skynet.start(function()
	DBCONNET()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = CMD[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
   skynet.register "mysqldb"
end)