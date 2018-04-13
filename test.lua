function urlEncode(s)  
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)  
    return string.gsub(s, " ", "+")  
end 

function Extract_cityname(res)
    local str_len = string.len(res)
    local str = string.byte(res,str_len,str_len)
    local judge_flag = nil
    local head = 0 
    local tail = 0
    for i = str_len,1,-1 do
        if(judge_flag == nil and string.byte(res,i,i) ~= str) then
            tail = i
            judge_flag = true
        end
        if(judge_flag ~= nil and string.byte(res,i,i) == str) then
            head = i+1
            break
        end
   end
   return string.sub(res,head,tail)
end


function Unicode_utf8_url(res)
    utf = {}
    utf[0] = bit.bor(0x80,bit.band(res,0x3F))
    utf[1] = bit.bor(0x80,bit.band(bit.arshift(res,6),0x3F))
    utf[2] = bit.bor(0xe0,bit.band(bit.arshift(res,12),0xF))
    return utf
end

function To_urlcode(res)
    local str = string.rep(res,1)
    --local str = Extract_json_cityname(res)
    local code_arr = {}
    local utf_code = ''
    local n = string.len(res)/5
    for i = 0 , n-1 do
        code_arr = Unicode_utf8_url(tonumber(string.sub(str, i*5+2,i*5+5),16))
        for j = 2,0,-1 do
        utf_code = utf_code..string.format("%c",code_arr[j])
        end
    end
    print(code_arr[1])
    print(urlEncode(utf_code))
end
