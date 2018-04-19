--定义全局变量
HTTP_result = nil
Weather_content = nil
string_result=""
tmr_over = false
cityname= nil
str_city = ''
APPID = "d1eb8e5e1993d169eefeffbcb9d73f6d"
lat = 0
lon = 0
--定义获取数据的函数
function urlEncode(s)  
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)  
    return string.gsub(s, " ", "+")  
end 

function Unicode_utf8_url(res)
    utf = {}
    utf[0] = bit.bor(0x80,bit.band(res,0x3F))
    utf[1] = bit.bor(0x80,bit.band(bit.arshift(res,6),0x3F))
    utf[2] = bit.bor(0xe0,bit.band(bit.arshift(res,12),0xF))
    return utf
end


function Extract_json_cityname(res)
    local city_name = ''
    _, _, city_name = string.find(res,'"city":"([^"]+)",')
    return city_name
end

function To_urlcode(res)
    local str = Extract_json_cityname(res)
    local code_arr = {}
    local utf_code = ''
    local n = string.len(str)/6
    print(str)
    for i = 0 , n-1 do
        code_arr = Unicode_utf8_url(tonumber(string.sub(str, i*6+3,i*6+6),16))
        for j = 2,0,-1 do
        utf_code = utf_code..string.format("%c",code_arr[j])
        end
    end
    return urlEncode(utf_code)
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
        if (code > 0) then
            string_result = string.rep(data,1)
            HTTP_result = true
        end
        end)
end

function Get_woeid(res)
    local url = 'http://sugg.us.search.yahoo.net/'
    url = url..'gossip-gl-location/?appid=weather&output=xml&command='
    url = url..To_urlcode(res)
    http.get(url,nil,function(code,data)
        if(code>0) then
            HTTP_result = true
            _, _,lat = string.find(data,"lat=([0-9]+)")
            _, _,lon = string.find(data,"lon=([0-9]+)")
        end
    end)
end
            
function Get_weather()
    url = "http://api.openweathermap.org/data/2.5/forecast/daily?"
    url = url.."lat="..lat
    url = url.."&lon="..lon
    url = url.."&cnt=2"
    url = url.."&APPID="..APPID
    http.get(url,nil,function(code,data)
        if(code>0) then
             print("GET Weather")
             HTTP_result = true
             string_result = string.rep(data,1)
        end
        end)
end

--调用函数
HTTP_result = nil
tmr.alarm(2,2000,tmr.ALARM_SEMI,function()
    Get_location_city()
    if(HTTP_result ~= nil) then
        HTTP_result = nil
        tmr.stop(2)
        tmr.unregister(2)
        tmr.alarm(3,2000,tmr.ALARM_SEMI,function()
            Get_woeid(string_result)
            if(HTTP_result ~= nil) then
                HTTP_result = nil
                tmr.stop(3)
                tmr.unregister(3)
                tmr.alarm(4,3000,tmr.ALARM_SEMI,function()
                    Get_weather()
                    if(HTTP_result ~= nil) then
                        HTTP_result = nil
                        tmr.stop(4);
                        tmr.unregister(4)
                        collectgarbage()
                        print("do file w2812")
                        dofile("WS2812.lua")
                    else
                        tmr.start(4)
                    end
                end)
            else
                tmr.start(3);      
            end
        end)
    else
        tmr.start(2);
    end
end)

