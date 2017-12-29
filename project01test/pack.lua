local cjson = require "cjson"
json=cjson.new()
local proto = require "proto"
local xxtea = require"xxtea";
local key = "IKidsE89S&(F9E(&*&6"
function printtable( t ,s)
	s=s..s
	for k,v in pairs(t) do
		print(s,k,v)
		if type(v)=="table" then
			printtable(v,s)
		end
	end
end

function reverseproto( t )
	local x = {}
	for i,v in pairs(t) do
		if t[t[i]] and type(i)=="number" then
			x[t[i].."@table"]=reverseproto(t[t[i]])
		end
		if type(v)~="table" then
			x[v]=i
		end
	end
	return x
end
local reproto = reverseproto(proto)

for k,v in pairs(reproto) do
	if type(v)=="number" then
		reproto[k]=tostring(v)
	end
end
 -- printtable(reproto,"**")
local pack = {}

function encodeleaf( check_table , pri_table )
	-- if #check_table==0 then
	-- 	return pri_table
	-- end
	-- local reverse = {}
	-- for i,v in ipairs(check_table) do
	-- 	reverse[v]=i
	-- end
	if not check_table then
		return pri_table
	end
	local count = 0
	for k,v in pairs(check_table) do
		count=count+1
		break
	end
	if count==0 then
		return pri_table
	end

	local reverse = check_table
	local newtable = {}
	for k,v in pairs(pri_table) do
		local x = reverse[k]
		if x then
			newtable[x]=v
			if type(v)=="table" then
				-- newtable[x] = encodeleaf(check_table[check_table[x]],v)
				newtable[x] = encodeleaf(check_table[k.."@table"],v)
			end
		else
			print("proto haven't this :",k,v)
			return
		end
	end
	return newtable
end

function copytable( t )
	local x = {}
	for k,v in pairs(t) do
		x[k]=v
	end
	return x
end

function pack.encode( t2 )--传入一个table,压成json
	local t = copytable( t2 )
	if t.action then
		local x = t.action
		t.action=nil
		local newtable = encodeleaf(reproto,{[x]=t})
		-- return json.encode(newtable)
		return xxtea.encrypt(json.encode(newtable), key)
	end
end

function decodeleaf( proto_table , decode_table )
	if not proto_table then
		return decode_table
	end
	if #proto_table==0 then
		return decode_table
	end
	local newtable = {}
	for i,v in ipairs(proto_table) do
		if decode_table[i] then
			newtable[v]=decode_table[i]
			if type(decode_table[i])=="table" then
				newtable[v]=decodeleaf(proto_table[v],decode_table[i])
			end
		end
	end
	return newtable
end

function pack.decode( t )--传入一个得到的json字符串,得到一个table
	--t is a json string,need to adapt proto
	local t = xxtea.decrypt(t, key)
	if t=="" or not t then
		print("xxtea decrypt fail!")
		return nil
	end
	t=json.decode(t)
	local newtable = {}
	local actionindex 
	for k,v in pairs(t) do
		actionindex = k
	end
	local action=proto[tonumber(actionindex)]
	if action then
		newtable=t[actionindex]
		newtable=decodeleaf(proto[action],newtable)
		newtable.action=action
		return newtable
	else
		print("decode error,illegal json string",t)
	end--传入一个得到的json字符串,得到一个table
end

return pack
