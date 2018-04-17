require("get_location.lua")

function Ws2812_Set(res)
	local Tady_Temp = ''
	local Tomor_Temp = ''
	_, _, Tady_Temp = tonumber(string.gfind(res,'"day":([1-9]+),'))
	_, _, Tomor_Temp = tonumber(string.gfind(res,'"day":([1-9]),'))
	ws2812.init()
	local color = ''
	if(Tomor_Temp*10 - Tady_Temp*10 > Tady_Temp) then 
		for i =1 , 18 do
			color = color.."0,255,0"
		end
		ws2812.write(string.char(color))
	end
	else if(Tady_Temp*10 - Tomor_Temp*10 < Tady_Temp) then
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
		tmr.register(5)
		dofile("get_location.lua")
	end
end)