wifi_wait = 0
    tmr.alarm(1,1000,tmr.ALARM_AUTO,function()
        if (wifi.sta.getip() == nil) then
            wifi_wait = wifi_wait + 1
            if (wifi_wait > 10) then
               wifi_wait = 0
            end
        else
            tmr.stop(1)
            dofile("get_location.lua")
        end
    end)