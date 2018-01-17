# lua-mhz19

Lua+ESP8266, read MH-Z19, send to LogStash

## Hardware

* WeMos
  * 5V power in
* MH-Z19
  * 5V VIN

Connect MH-Z19 PWM output to D3 on WeMos.

## Firware requirements

Firmware needs to be built with the following modules:

* gpio
* http
* sjson
* tmr
* wifi
