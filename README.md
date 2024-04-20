# WeatherInformer
Экран отображения погоды с прогнозом 2 дня для устройства ESP32-4848S040 под управлением Domoticz

1) https://www.domoticz.com/
2) https://mosquitto.org/
3) https://www.openhasp.com/0.7.0/
4) https://github.com/FlyingDomotic/domoticz-mqttmapper-plugin
5) https://www.visualcrossing.com

![photo_2024-04-20 08 32 56](https://github.com/kovainfo/WeatherInformer/assets/36986231/d714e24c-c74e-4ac1-a77a-cf16d447cc32)

# Установка и настройка:

1) Установить и настроить domoticz, mosquitto
2) Установить клиенты mosquitto_pub и mosquitto_sub
3) Установить плагин для domoticz (domoticz-mqttmapper-plugin)
  * на самом деле, можно было бы обойтись только одним этим плагином, но тогда домотикз создаст более 10-15 устройств лишних ?ненужных?
  * добавить (или заменить содержимое файла) настройки плагина /domoticz/MqttMapper.json
4) Установить OpenHasp на устройство ESP32-4848S040
  * можно через браузер: https://nightly.openhasp.com
  * прошивка Guition ESP32-S3-4848S040 / 16 MB / ST7701S / GT911
  * через WEB интерфейс устройства залить в него (в корень) файлы из папки /ESP32-4848S040
5) для корректной работы в настройках экрана через WEB интерфейс нужно выбрать:
  * HASP Design -> UI Theme: Material Dark (усли значение другое - возможно придётся донастраивать pages.jsonl - поползут цвета)
  * Configuration -> MQTT Settings -> Host Name: main_door (если значение другое, его надо заменить в файле MqttMapper.json)
6) Создать скрипт автоматизации в Domoticz типа dzVents и поместить туда содержимое файла /domoticz/zdvents_WeatherInformer.lua
7) Зарегистрироваться на https://www.visualcrossing.com , получить API KEY и подставить в скрипт domoticz
8) вставить GPS координаты места, где хотим видеть прогноз на 2 дня
9) Готово!


