local ERRORCODE = require "errorcode"
local utityhelp = {}
function utityhelp.DelstrFl(s)--去除str首尾空白
    s=tostring(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function utityhelp.checkMempty(s )
	s=tostring(s)
	local str,num=string.gsub(s,"%s+","")
	return num
end

function utityhelp.strlen(str)
	str=tostring(str)
    local fontSize = 20
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        -- local char = string.sub(str, i, i+byteCount-1)
        i = i + byteCount
        count = count + 1
    end
    return count
end

function utityhelp.lawfulusername( username )
	local num
	username=utityhelp.DelstrFl(username)
	if username==nil or username=="" then
		return false,ERRORCODE.emptyusername
	end
	num=utityhelp.checkMempty(username)
	if num>0 then
		return false,ERRORCODE.containempty
	end
	if utityhelp.strlen(username)>8 then
		return false,ERRORCODE.usernametoolong
	end
	if utityhelp.strlen(username,0,2)=="yk" then
		return false,ERRORCODE.illegalusername
	end
	return true
end

function utityhelp.lawfuluaccount( uaccount )
	local num
	uaccount=utityhelp.DelstrFl(uaccount)
	if uaccount==nil or uaccount=="" then
		return false,ERRORCODE.emptyuaccount
	end
	num=utityhelp.checkMempty(uaccount)
	if num>0 then
		return false,ERRORCODE.emptyuaccount
	end
	if utityhelp.strlen(uaccount)~=string.len(uaccount) then
		return false,ERRORCODE.uaccountchinese
	end
	if utityhelp.strlen(uaccount)>8 then
		return false,ERRORCODE.uaccounttoolong
	end
	if string.sub(uaccount,0,2)=="yk" then
		return false,ERRORCODE.illegal
	end
	return true
end

function utityhelp.lawfulupassword( upassword )
	local num
	upassword=utityhelp.DelstrFl(upassword)
	print("upassword",upassword)
	if upassword==nil or upassword=="" then
		return false,ERRORCODE.emptyupassword
	end
	num=utityhelp.checkMempty(upassword)
	if num>0 then
		return false,ERRORCODE.upasswordMempty
	end
	if utityhelp.strlen(upassword)~=string.len(upassword) then
		return false,ERRORCODE.upasswordchinese
	end
	if string.len(upassword)>=21 then
		return false,ERRORCODE.upasswordtoolong
	end
	print(string.len(upassword),"-----------",upassword)
	if string.len(upassword)<=5 then
		return false,ERRORCODE.upasswordtooshort
	end
	return true
end

function utityhelp.lawfulbankpassword( bankpassword )	
	local num
	bankpassword=utityhelp.DelstrFl(bankpassword)
	if bankpassword==nil or bankpassword=="" then
		return false,ERRORCODE.emptyupassword
	end
	num=utityhelp.checkMempty(bankpassword)
	if num>0 then
		return false,ERRORCODE.upasswordMempty
	end
	if utityhelp.strlen(bankpassword)~=string.len(bankpassword) then
		return false,ERRORCODE.upasswordchinese
	end
	if string.len(bankpassword)>9 then
		return false,ERRORCODE.upasswordtoolong
	end
	if string.len(bankpassword)<6 then
		return false,ERRORCODE.upasswordtooshort
	end
	return true
end

function utityhelp.timetotime( time1,time2 )
	local d1,h1,m1,s1=string.match(time1,"(%d+)-(%d+)-(%d+)-(%d+)")
	local d2,h2,m2,s2=string.match(time2,"(%d+)-(%d+)-(%d+)-(%d+)")
	if d1~=d2 then
		h1,m1,s1=0,0,0
	end
	return (h2-h1)*3600+(m2-m1)*60+(s2-s1)
end

function utityhelp.yesterdayonlinetime( time1,time2 )
	local d1,h1,m1,s1=string.match(time1,"(%d+)-(%d+)-(%d+)-(%d+)")
	local d2,h2,m2,s2=string.match(time2,"(%d+)-(%d+)-(%d+)-(%d+)")
	if d1~=d2 then
		h2,m2,s2=24,0,0
	end
	return (h2-h1)*3600+(m2-m1)*60+(s2-s1)
end

return utityhelp
