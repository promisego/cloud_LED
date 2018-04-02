--定义全局变量
Http_result = nil
string_result=""
--定义获取数据的函数

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

--调用函数

tmr.alarm(2,1000,tmr.ALARM_AUTO,function()
    Get_location_city()
    if(Http_result ~= nil) then
        tmr.stop(2)
        print(string_result)
        print(string.find(string_result , "中"))
        print(string.find(string_result,[^\u4e00-\u9fa5],9))
        local param1 ,_= string.find(string_result,"\S")
        local str = string.sub(string_result,1,param1)
        str = string.reverse(str)
        print(param1)
    end
    end)
