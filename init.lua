KEY = 1
TMR_WIFI = 4
gpio.mode(KEY,gpio.INPUT)
print('Setting up WIFI...')
tmr.delay(1000000)
wifi_status = nil

-------------
-- wifi
-------------
file.open("WifiInfo.lua","r") 
W={};       
W.ssid=string.sub(file.readline(),1,-2);
W.pwd=string.sub(file.readline(),1,-2);
file.close();
file.flush();
wifi.sta.config(W)
W.ssid = 'nodemcu'
W.pwd = '12345678'
wifi.ap.config(W)
wifi.setmode(wifi.STATION)
wifi.sta.autoconnect(1)

--wifi hettpserver
KEY_Status = gpio.read(KEY)
if(KEY_Status == 1) then
	wifi.setmode(wifi.STATIONAP)
	dofile("httpServer.lua")
	httpServer:listen(80)
	httpServer:use('/config', function(req, res)
		if req.query.ssid ~= nil and req.query.pwd ~= nil then
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
	dofile("soil_humidity.lua")
end
