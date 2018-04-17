require("get_location.lua")

function Ws2812_Set(res)
	local string = string.rep(res,1)
	local Tady_Temp_H = 0
	local Tomor_Temp_H = 0
	local Tady_Temp_L =0
	local Tomor_Temp_L = 0
	local Start = ''
	local Weather = 0
	local flicker = 1
	_, Start, Tady_Temp_H = tonumber(string.find(res,'"max":([1-9]+)'))
	_, _, Tomor_Temp_H = tonumber(string.find(res,'"max":([1-9])',tonumber(Start)))
	_, Start, Tady_Temp_L = tonumber(string.find(res,'"min":([1-9])'))
	_, Start, Tomor_Temp_L = tonumber(string.find(res,'"min":([1-9])',tonumber(Start)))
	_, _, Weather = string.find(res,'"id":([1-9])',tonumber(Start))
	if tonumber(Weather)>5 and tonumber(Weather) < 9 then
		flicker = 0
	ws2812.init()
	local color = ''
	if(Tomor_Temp_H*10 - Tady_Temp_H*10 > Tady_Temp_H) and flicker == 0 then 
		for i =1 , 18 do
			color = color.."0,255,0"
		end
		ws2812.write(string.char(color))
	end
	else if(Tady_Temp_L*10 - Tomor_Temp_L*10 < Tady_Temp_L) or flicker == 1 then
		for i = 1,18 do
			color = color.."255,0,0"
		end
		ws2812.write(string.char(color))
	end
	else
		for i =1 ,18 do
			color = color.."0,0,0,255"
		end
		ws2812.write(string.char(color))
	end
end

Ws2812_Set()
n = 0
tmr.register(5,3600000,ALARM_AUTO,function()
	n = n +1
	if(n == 3) then
		tmr.stop(5)
		tmr.unregister(5)
		dofile("get_location.lua")
	end
end)