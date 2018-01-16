
local MHZ19_PIN = 1
local TRIGGER_ON = "both"

-- TODO externalize configuration
WIFI_PASSWORD="TODO"
WIFI_SSID="TODO"
LOGSTASH="http://192.168.178.2:999999"

local lowDuration
local highDuration
local lastTimestamp

local latestMeasurements = {}

local function calculateCo2(highDuration, lowDuration)
        -- TODO calculate CO2 using the formula
    return TODO
end

local function mhz19InterruptHandler(level, timestamp)
    print(level, timestamp)
    if level then
        highDuration = timestamp - lastTimestamp
    else
        lowDuration = timestamp - lastTimestamp
        local co2 = calculateCo2(highDuration, lowDuration)
        table.insert(latestMeasurements, co2)
    end
    lastTimestamp = timestamp
end

do
    gpio.mode(MHZ19_PIN, gpio.INT)
    trig(MHZ19_PIN, TRIGGER_ON, mhz19InterruptHandler)


    -- TODO timer 60s
    -- TODO collect values + avg of three medians
    -- TODO connect to WiFi
    -- TODO POST to LogStash

end
