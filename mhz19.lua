local MHZ19_PIN = 1
local TRIGGER_ON = "both"
local SEND_INTERVAL_MS = 30 * 1000

-- use envsubst to replace the placeholders with actual values
WIFI_SSID = "${WIFI_SSID}"
WIFI_PASSWORD = "${WIFI_PASSWORD}"
LOGSTASH_URL = "${LOGSTASH_URL}"

local lowDuration
local highDuration
local lastTimestamp

local latestMeasurements = {}

local function calculateCo2Ppm(highDuration, lowDuration)
    return 5000.0 * (1002.0 * highDuration - 2.0 * lowDuration) / 1000.0 / (highDuration + lowDuration);
end

local function mhz19InterruptHandler(level, timestamp)
    print(level, timestamp)
    -- TODO log event
    if (level) then
        highDuration = timestamp - lastTimestamp
    else
        lowDuration = timestamp - lastTimestamp
        local co2 = calculateCo2Ppm(highDuration, lowDuration)
        table.insert(latestMeasurements, co2)
        -- TODO log CO2 reading
    end
    lastTimestamp = timestamp
end

local function httpPostCallback(status_code, body, headers)
    if (status_code < 0) then
        -- TODO log error
    else
        -- TODO log success
    end
end

local function sendReadingsToLogstash()
    -- get a median of the latest CO2 readings
    local measurements = latestMeasurements
    latestMeasurements = {}
    table.sort(measurements)
    local median = measurements[math.ceil(#measurements / 2 + 1)]

    -- POST to LogStash
    local message = {}
    message["co2"] = median
    message["temperature"] = TODO
    message["humidity"] = TODO

    local jsonMessaage = sjson.encode(message)

    http.post(LOGSTASH_URL, nil, jsonMessaage, httpPostCallback)
end

do
    -- configure reading of MHZ19
    gpio.mode(MHZ19_PIN, gpio.INT)
    trig(MHZ19_PIN, TRIGGER_ON, mhz19InterruptHandler)

    -- TODO log wifi status events (if it isn't logged already)
    -- TODO wifi.eventmon...

    -- connect to WiFi
    wifi.setmode(wifi.STATION)
    wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)
    wifi.sta.connect()

    -- configure sending to LogStash
    timer = tmr.create(TODO)
    tmr.alarm(timer, SEND_INTERVAL_MS, tmr.ALARM_AUTO, sendReadingsToLogstash)
end
