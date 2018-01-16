-- blink
gpio.mode(3, gpio.OUTPUT)
while 1 do
    gpio.write(3, gpio.HIGH)
    tmr.delay(1000000)   -- wait 1,000,000 us = 1 second
    gpio.write(3, gpio.LOW)
    tmr.delay(1000000)   -- wait 1,000,000 us = 1 second
end



-- blink async

-- Pin definition
local pin = 3
local status = gpio.LOW
local duration = 1000    -- 1 second duration for timer

-- Initialising pin
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, status)

-- Create an interval
tmr.alarm(0, duration, 1, function ()
    if status == gpio.LOW then
        status = gpio.HIGH
    else
        status = gpio.LOW
    end

    gpio.write(pin, status)
end)



-- wifi

wifi.setmode(wifi.STATION)

wifi.sta.config("accesspointname","yourpassword")
wifi.sta.connect()
tmr.delay(1000000)   -- wait 1,000,000 us = 1 second
print(wifi.sta.status())
print(wifi.sta.getip())



-- http request with IP

sk=net.createConnection(net.TCP, 0)
sk:on("receive", function(sck, c) print(c) end )
sk:connect(80,"104.236.193.178")
sk:send("GET /testwifi/index.html HTTP/1.1\r\nHost: wifitest.adafruit.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")



-- http request with hostname

sk=net.createConnection(net.TCP, 0)
sk:on("receive", function(sck, c) print(c) end )
sk:connect(80,"wifitest.adafruit.com")
sk:send("GET /testwifi/index.html HTTP/1.1\r\nHost: wifitest.adafruit.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
