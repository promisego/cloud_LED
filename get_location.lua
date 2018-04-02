--定义全局变量
Http_result = 0
--定义获取数据的函数
function Get_location_city()
    local url="http://int.dpool.sina.com.cn/iplookup/iplookup.php"
    local wifi_status=wifi.sta.status()
    http.get(url,nil,function(code,data)
        Http_result = 0
        if (code<0) then
            print("HTTP fail")
        else
            print(data)
            Http_result = 1
        end
        end)
end

--调用函数

tmr.alarm(2,1000,tmr.ALARM_AUTO,function()
    Get_location_city()
    if(Http_result ~= 0) then
        tmr.stop(2)
    end
    end)