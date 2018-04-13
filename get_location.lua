--定义全局变量
HTTP_result = nil
Weather_content = nil
string_result=""
cityname= nil
str_city = ''
--定义获取数据的函数
local function urlEncode(s)  
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
   return head,tail
end

function Extract_json_cityname(res)
    local city_name = ''
    _, _, city_name = string.find(res,'"city":"([^"]+)",')
    return city_name
end

function Get_ip()
    local url = "http://ip.qq.com/cgi-bin/index"
    http.get(url,nil,function(code,data)
        if(code>0) then
        print(code,data)
        end
        end)
end

function Get_location_city()
    local url="http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=js"
    local head
    local wifi_status=wifi.sta.status()
    http.get(url,nil,function(code,data)
        HTTP_result = nil
        if (code<0) then
            print("HTTP fail")
        else
            string_result = string.rep(data,1)
            Http_result = true
        end
        end)
end

function Get_woeid(city_name)
    local url = 'http://sugg.us.search.yahoo.net/'
    url = url..'gossip-gl-location/?appid=weather&output=xml&command='
    url = url..urlEncode(city_name)
    http.get(url,nil,function(code,data)
        if(code>0) then
            HTTP_result = true
            print(data)
            
        end
    end)
end
            
function Get_weather(city_name)
    local url = 'http://sugg.us.search.yahoo.net/gossip-gl-location/?appid=weather&output=xml&command='
    url = url..urlEncode(city_name)
    --url = url..'%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
     http.get(url,nil,function(code,data)
        if(code>0) then
             Http_result = true
             Weaather_content = string.rep(data,1)
        end
        end)
end

--调用函数
tmr.alarm(2,2000,tmr.ALARM_AUTO,function()
    local head,tail
    Get_location_city()
    if(Http_result ~= nil) then
        HTTP_result = nil
        tmr.stop(2)
        print(Extract_json_cityname(string_result))
        --print(sjson.decode(string_result))
        collectgarbage()
        tmr.alarm(3,10000,tmr.ALARM_AUTO,function()
            Get_weather(str_city)
            collectgarbage()
            if(HTTP_result ~= nil) then
                tmr.stop(3)
                HTTP_result = nil
                print(Weather_content)
        end
        end)
    end
    end)
