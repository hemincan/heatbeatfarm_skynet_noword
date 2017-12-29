local xxtea = require("xxtea");
local key = "wibkis3544424*-2"
function printbit( str )
	local str = string.pack(">s2",str)
	local long = string.byte(str,2)
	for i=1,long+2 do
		io.write(string.byte(str,i).."  ")
	end
	print()
end

local x = "4��=�����͚����g���=��^����p|��o�@�q��9��7s�Uޙ.~�YpO~K]ڪl_��'`�"
print(xxtea.decrypt(x,key))
-- local text = "hello";
-- local key = "key";
-- local encrypt_data = xxtea.encrypt(text, key);
--  print(" encrypt_data ", encrypt_data )
-- -- printbit(encrypt_data)
-- local decrypt_data = xxtea.decrypt(encrypt_data, "key");
-- if not decrypt_data then
-- 	print("decrypt_data is nil")
-- elseif decrypt_data=="" then
-- 	print("is empty")
-- end
-- print(" decrypt_data ", decrypt_data )
-- -- printbit(decrypt_data)
-- -- if text == decrypt_data then
-- --     print("success!\n");
-- -- else
-- --     print("fail!\n");
-- -- end
-- -- printbit("sdfsdf")