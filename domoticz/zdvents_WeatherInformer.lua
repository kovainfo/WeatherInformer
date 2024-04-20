local response = "VC_response"
local s_devices = { "движение1","движение2","движение3" } -- turn ON/OFF screen when no motion
local w_informer = "Информер - статус"
local a_informer = "Информер - alarm"

local localTempDevice = "Улица - t° C"

local VC_API_KEY = "" -- API KEY from visualcrossing.com
local VCaddress = "" -- GPS Coords

return {
    on =        {       
                        timer           =   { "every 5 minutes" },
                        devices         =   { s_devices[1], s_devices[2], s_devices[3], w_informer, a_informer, "Alarm" },
                        httpResponses   =   {  response } },                         
              
    logging =   {       level   =   domoticz.LOG_DEBUG,      -- change to LOG_ERROR when script runs without problems ( LOG_DEBUG )                                 
                        marker  =   "getTemperaturesVC" },                                           

    execute = function(dz, item)
        local MQTTcmdtopic = "hasp/main_door/command/"
                
        local function logWrite(str,level)
            dz.log(tostring(str),level or dz.LOG_DEBUG)
        end

        local function sendMQTT(message, topic)
            local MQTTTopic = topic or 'domoticz/out'
            logWrite("MQTTMessage : " .. message   )
            dz.utils.osExecute( 'mosquitto_pub ' ..  ' -t '  .. MQTTTopic .. " -m '" .. message .. "'")
        end 

        if item.isHTTPResponse then
            local retn = {"Вс","Пн","Вт","Ср","Чт","Пт","Сб","Вс" }
            local currentTemp = string.format("%.1f", dz.devices( localTempDevice ).temperature )
            local currentHum  = dz.devices( localTempDevice ).humidity
            
            local currentIcon = item.json.currentConditions.icon
            local currentMax  = string.format("%.1f", item.json.days[1].tempmax )
            local currentMin  = string.format("%.1f", item.json.days[1].tempmin )
            local currentname = retn[ tonumber(os.date("%w", item.json.days[1].datetimeEpoch ))+1 ]
            local currentdate = os.date("%d.%m", item.json.days[1].datetimeEpoch )

            local forecast0Icon = item.json.days[1].icon

            local forecast1Icon = item.json.days[2].icon
            local forecast1Max  = string.format("%.1f", item.json.days[2].tempmax )
            local forecast1Min  = string.format("%.1f", item.json.days[2].tempmin )
            local forecast1name = retn[ tonumber(os.date("%w", item.json.days[2].datetimeEpoch ))+1 ]
            local forecast1date = os.date("%d.%m", item.json.days[2].datetimeEpoch )
            
            local forecast2Icon = item.json.days[3].icon
            local forecast2Max  = string.format("%.1f", item.json.days[3].tempmax )
            local forecast2Min  = string.format("%.1f", item.json.days[3].tempmin )
            local forecast2name = retn[ tonumber(os.date("%w", item.json.days[3].datetimeEpoch ))+1 ]
            local forecast2date = os.date("%d.%m", item.json.days[3].datetimeEpoch )

            sendMQTT( "1", MQTTcmdtopic .. "page")
            
            sendMQTT( currentTemp .. "°C", MQTTcmdtopic .. "p1b2.text")
            sendMQTT( currentHum .. "%", MQTTcmdtopic .. "p1b3.text")
            sendMQTT( "L:/main_" .. currentIcon .. ".png", MQTTcmdtopic .. "p1b1.src")

            -- today forecast
            sendMQTT( currentname, MQTTcmdtopic .. "p1b14.text")
            sendMQTT( currentdate, MQTTcmdtopic .. "p1b15.text")
            sendMQTT( "L:/icon_" .. forecast0Icon .. ".png", MQTTcmdtopic .. "p1b16.src")
            sendMQTT( currentMin .. "° .. " .. currentMax .. "°", MQTTcmdtopic .. "p1b17.text")
            -- forecast +1
            sendMQTT( forecast1name, MQTTcmdtopic .. "p1b24.text")
            sendMQTT( forecast1date, MQTTcmdtopic .. "p1b25.text")
            sendMQTT( "L:/icon_" .. forecast1Icon .. ".png", MQTTcmdtopic .. "p1b26.src")
            sendMQTT( forecast1Min .. "° .. " .. forecast1Max .. "°", MQTTcmdtopic .. "p1b27.text")
            --forecast +2
            sendMQTT( forecast2name, MQTTcmdtopic .. "p1b34.text")
            sendMQTT( forecast2date, MQTTcmdtopic .. "p1b35.text")
            sendMQTT( "L:/icon_" .. forecast2Icon .. ".png", MQTTcmdtopic .. "p1b36.src")
            sendMQTT( forecast2Min .. "° .. " .. forecast2Max .. "°", MQTTcmdtopic .. "p1b37.text")
        end
        
        -- ALARM BUTTON SCREEN --
        if (item.changed and item.name == a_informer and dz.devices("Alarm").state ~= "On") then 
            if dz.devices( a_informer ).levelName == "Hold" then
                logWrite( "SET ALARM" )
                dz.devices("Alarm").switchOn()
                sendMQTT( "L:/armed.png", MQTTcmdtopic .. "p2b100.src")
            end
        end
        if (item.changed and item.name == "GW_Alarm") then 
            if dz.devices( "Alarm" ).state == "Off" then
                logWrite( "DISARM ALARM" )
                sendMQTT( "L:/disarm2.png", MQTTcmdtopic .. "p2b100.src")
            end
        end
        -- ALARM BUTTON SCREEN --
        
        if (item.isTimer or item.name == w_informer) then
            logWrite( "Read weather forecast" )
            local url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/" .. VCaddress .. "?unitGroup=metric&key=" .. VC_API_KEY .. "&contentType=json&lang=ru&include=days,current"
            dz.openURL({
                  url = url,
                        method = "GET",
                        callback = response})
        else
            if (item.name == s_devices[1] or item.name == s_devices[2] or item.name == s_devices[3]) then
                if (item.state == "On") then
                    logWrite( "Turn on WeatherInformer" )
                    sendMQTT( "1", MQTTcmdtopic .. "backlight")
                    sendMQTT( "255", MQTTcmdtopic .. "backlight")
                end
                if (dz.devices( s_devices[1] ).state == "Off" and
                    dz.devices( s_devices[2] ).state == "Off" and
                    dz.devices( s_devices[3] ).state == "Off") then
                    logWrite( "Turn off WeatherInformer" )
                    sendMQTT( "0", MQTTcmdtopic .. "backlight")
                end
            end
        end
    end
}
