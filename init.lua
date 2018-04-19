KEY = 6
TMR_WIFI = 4
gpio.mode(KEY,gpio.INPUT,gpio.PULLUP)
tmr.delay(10000)
wifi_status = nil

-------------
-- wifi
-------------
if file.open("WifiInfo.lua","r") then
W={};       
W.ssid=string.sub(file.readline(),1,-2);
W.pwd=string.sub(file.readline(),1,-2);
file.close();
file.flush();
wifi.sta.config(W)
end
wifi.sta.autoconnect(1)
W.ssid = 'nodemcu'
W.pwd = '12345678'
wifi.ap.config(W)
wifi.setmode(wifi.STATION)

--wifi hettpserver
if(KEY_Status == 0) then
	wifi.setmode(wifi.STATIONAP)
	dofile("httpServer.lua")
	httpServer:listen(80)
	httpServer:use('/config', function(req, res)
		if req.query.ssid ~= nil and req.query.pwd ~= nil then
            if file.open("WifiInfo.lua","w+") then
            file.writeline(req.query.ssid)
            file.writeline(req.query.pwd)
            file.close();
            file.flush();
            end
            W.ssid = req.query.ssid
            W.pwd = req.query.pwd
			wifi.sta.config(W)

			wifi_status = 1
			tmr.alarm(TMR_WIFI, 1000, tmr.ALARM_AUTO, function()
				wifi_status = wifi.sta.status()
				if wifi_status ~= 1 then
					res:type('application/json')
					res:send('{"status":"' .. wifi_status .. '"}')
                    print('send ok')
					tmr.stop(TMR_WIFI)
				end
			end)
		end
	end)

	httpServer:use('/scanap', function(req, res)
		wifi.sta.getap(function(table)
			local aptable = {}
			for ssid,v in pairs(table) do
				local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
				aptable[ssid] = {
					authmode = authmode,
					rssi = rssi,
					bssid = bssid,
					channel = channel
				}
			end
			res:type('application/json')
			res:send(cjson.encode(aptable))
		end)
	end)
else
    wifi_wait = 0
    tmr.alarm(0,5000,tmr.ALARM_SEMI,function()
        if (wifi.sta.getip() == nil) then
            tmr.start(0)
        else
            tmr.stop(0)
            tmr.unregister(0)
            dofile("get_location.lua")
        end
    end)
end
