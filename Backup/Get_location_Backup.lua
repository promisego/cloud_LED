HTTP_result = nil
tmr.alarm(2,2000,tmr.ALARM_AUTO,function()
    Get_location_city()
    if(HTTP_result ~= nil) then
        HTTP_result = nil
        tmr.stop(2)
        tmr.unregister(2)
        tmr.alarm(3,2000,tmr.ALARM_AUTO,function()
            Get_woeid(string_result)
            collectgarbage()
            if(HTTP_result ~= nil) then
                HTTP_result = nil
                while( not tmr.stop(3))  do
                    tmr.delay(1000)
                end
                tmr.unregister(3)
                tmr.alarm(4,5000,tmr.ALARM_AUTO,function()
                    Get_weather()
                    if(HTTP_result ~= nil) then
                        while(not tmr.stop(4)) do
                            tmr.delay(1000)
                        end
                        tmr.unregister(4)
                        print("do file w2812")
                        dofile("W2812.lua")
                    end
                end)      
        end
        end)
    end
    end)