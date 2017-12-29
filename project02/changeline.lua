
local s = "花样百出3sfasdfasdfasdfdf奇趣地地地地要一一上枯叶 一一一一桍 地地要夺桍"
function string.utf8len(input)  
    local len  = string.len(input)  
    local left = len  
    local cnt  = 0  
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc} 
    local index = 1 
    local newstring = ""
    local withe = 0 
    local witheadd2 = false
    while left ~= 0 do
        local tmp = string.byte(input, -left)  
        local i   = #arr  
        while arr[i] do  
            if tmp >= arr[i] then  
                left = left - i  
                withe=withe+2
                witheadd2 = true
                break  
            end  
            i = i - 1  
        end
        if not witheadd2 then
        	withe=withe+1
        end
        witheadd2=false
        if withe >=10 then
        	print(string.sub(input,index,withe),index,index+withe)
        	newstring=newstring..string.sub(input,index,index+withe).."\n"
        	index=index+withe+1
        	withe=0
        end
        cnt = cnt + 1  
    end  
    return cnt,newstring 
end  

-- function changeline( content )

-- end
local cnt,newstring = string.utf8len(s)
-- local len = string.len(newstring)
-- for i=1,len do
-- 	io.write(string.byte(newstring,i).." ")
-- end
print(newstring)