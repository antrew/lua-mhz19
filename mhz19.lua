do

    local MHZ19_PIN = 1
    local TRIGGER_ON = "both"
    local SEND_INTERVAL_MS = 30 * 1000

    -- use envsubst to replace the placeholders with actual values
    local WIFI_SSID = "${WIFI_SSID}"
    local WIFI_PASSWORD = "${WIFI_PASSWORD}"
    local LOGSTASH_URL = "${LOGSTASH_URL}"
    local DEVICE_ID = "${DEVICE_ID}"

    local lowDuration
    local highDuration
    local lastTimestamp

    local latestMeasurements = {}

    local function calculateCo2Ppm(highDuration, lowDuration)
        return 5000.0 * (1002.0 * highDuration - 2.0 * lowDuration) / 1000.0 / (highDuration + lowDuration);
    end

    local function mhz19InterruptHandler(level, timestamp)
        print("mhz19InterruptHandler", level, timestamp)
        if (level) then
            highDuration = timestamp - lastTimestamp
        else
            lowDuration = timestamp - lastTimestamp
            local co2 = calculateCo2Ppm(highDuration, lowDuration)
            table.insert(latestMeasurements, co2)
            print("co2", co2)
        end
        lastTimestamp = timestamp
    end

    local function httpPostCallback(status_code, body, headers)
        if (status_code < 0) then
            print("http error", status_code)
        else
            print("http done", status_code)
        end
    end

    local function sendReadingsToLogstash()
        print("sending readings to logstash")
        local message = {}

        -- get a median of the latest CO2 readings
        local measurements = latestMeasurements
        latestMeasurements = {}
        if (#measurements > 0) then
            table.sort(measurements)
            local median = measurements[math.ceil(#measurements / 2 + 1)]
            message["co2"] = median
        end

        -- TODO integrate temperature and humidity sensors
        message["temperature"] = 0
        message["humidity"] = 0

        -- POST to LogStash
        local jsonMessaage = sjson.encode(message)
        http.post(LOGSTASH_URL, nil, jsonMessaage, httpPostCallback)
    end

    -- configure reading of MHZ19
    gpio.mode(MHZ19_PIN, gpio.INT)
    gpio.trig(MHZ19_PIN, TRIGGER_ON, mhz19InterruptHandler)

    -- TODO log wifi status events (if it isn't logged already)
    -- TODO wifi.eventmon...

    -- connect to WiFi
    wifi.setmode(wifi.STATION)
    local wifiConfig = {}
    wifiConfig["ssid"] = WIFI_SSID
    wifiConfig["pwd"] = WIFI_PASSWORD
    wifi.sta.config(wifiConfig)
    wifi.sta.connect()

    -- configure sending to LogStash
    local timer = tmr.create()
    timer:alarm(SEND_INTERVAL_MS, tmr.ALARM_AUTO, sendReadingsToLogstash)
end
