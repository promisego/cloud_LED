--定义全局变量
Http_result = nil
Weather_result = nil
string_result=""
cityname_head = 0
cityname_tail = 0
str_city = ''
--定义获取数据的函数
function Get_ip()
    local url = "http://ip.qq.com/cgi-bin/index"
    http.get(url,nil,function(code,data)
        if(code>0) then
        print(code,data)
        end
        end)
end

function Get_location_city()
    local url="http://int.dpool.sina.com.cn/iplookup/iplookup.php?"
    local wifi_status=wifi.sta.status()
    http.get(url,nil,function(code,data)
        Http_result = nil
        if (code<0) then
            print("HTTP fail")
        else
            string_result = string.rep(data,1)
            Http_result = true
        end
        end)
end

function Get_cityname(res)
    local str_len = string.len(res)
    local str = string.byte(res,str_len,str_len)
    local judge_flag = nil
    cityname_head = 0
    cityname_tail = 0
    for i = str_len,1,-1 do
        if(judge_flag == nil and string.byte(res,i,i) ~= str) then
                cityname_tail = i
                judge_flag = true
        end
        if(judge_flag ~= nil and string.byte(res,i,i) == str) then
            cityname_head = i+1
            break
        end
   end
end

local function urlEncode(s)  
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)  
    return string.gsub(s, " ", "+")  
end  

function Get_weather(city_name)
    local url = 'https://query.yahooapis.com/v1/public/yql?q=select * from geo.placefinder where text="39.9919336,116.3404132" and gflags = "R"'
    --url = url..'%E5%8D%97%E6%98%8C'
    --url = url..'%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
     http.get(url,nil,function(code,data)
        if(code>0) then
            if(string.find(data,'Yahoo')) then
                Weather_result = true
            end
        end
        end)
end

--调用函数
       
tmr.alarm(3,2000,tmr.ALARM_AUTO,function()
    Get_location_city(str_city)
    if(Http_result ~= nil) then
        Http_result = nil
        tmr.stop(3)
        Get_cityname(string_result)
        str_city=string.sub(string_result,cityname_head,cityname_tail)
        print(str_city)
        collectgarbage()
        tmr.alarm(2,5000,tmr.ALARM_AUTO,function()
            Get_weather(str_city)
            collectgarbage()
            if(Weather_result ~= nil) then
            print(Weather_result)
            tmr.stop(2)
        end
        end)
    end
    end)
