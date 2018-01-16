local MHZ19_PIN = 1
local TRIGGER_ON = "both"
local SEND_INTERVAL_MS = 60000

-- TODO externalize configuration
WIFI_SSID = "TODO"
WIFI_PASSWORD = "TODO"
LOGSTASH = "http://192.168.178.2:999999"

local lowDuration
local highDuration
local lastTimestamp

local latestMeasurements = {}

local function calculateCo2Ppm(highDuration, lowDuration)
    return 5000.0 * (1002.0 * highDuration - 2.0 * lowDuration) / 1000.0
        / (highDuration + lowDuration);
end

local function mhz19InterruptHandler(level, timestamp)
    print(level, timestamp)
    if level then
        highDuration = timestamp - lastTimestamp
    else
        lowDuration = timestamp - lastTimestamp
        local co2 = calculateCo2Ppm(highDuration, lowDuration)
        table.insert(latestMeasurements, co2)
    end
    lastTimestamp = timestamp
end

local function sendReadingsToLogstash()
    -- TODO collect values + avg of three medians
    -- TODO POST to LogStash
end

do
    -- configure reading of MHZ19
    gpio.mode(MHZ19_PIN, gpio.INT)
    trig(MHZ19_PIN, TRIGGER_ON, mhz19InterruptHandler)

    -- connect to WiFi
    wifi.setmode(wifi.STATION)
    wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)
    wifi.sta.connect()

    -- configure sending to LogStash
    timer = tmr.create(TODO)
    tmr.alarm(timer, SEND_INTERVAL_MS, tmr.ALARM_AUTO, sendReadingsToLogstash)
end
