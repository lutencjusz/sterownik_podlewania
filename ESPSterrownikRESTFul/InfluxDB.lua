gpio.write (pin, LED_ON)
local licznikInfluxDB = 0

function zapiszInfluxDB (db, body)
http.post('http://192.168.0.11:8086/write?db=' ..db,
  'Content-Type: application/json\r\n', --bez tego komunikat jest nieprawidłowy
  body,
  function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code)
    end
    return code
  end)
end


function zapiszPTestoweInfluxDB ()
    tmr.alarm(3,1000,1,do_next_InfluxDB)
end 

function do_next_InfluxDB()
    if debugowanie then
        print (licznikInfluxDB) 
    end    
    if licznikInfluxDB == 0 then
        tmr.stop (3)
        licznikInfluxDB = licznikInfluxDB + 1
        tmr.alarm(4, 1000, tmr.ALARM_AUTO, function()
            if zapiszInfluxDB ("test", "temp,value=" ..pTestowe.temp .. "." .. pTestowe.temp_u
            .. ' kom="Temperatura powietrza"') ~= 204 then
                if debugowanie then
                    print ("zapiszPTestoweInfluxDB: Coś poszło nie tak przy temperaturze powietrza")
                end
            end
            if debugowanie then
                print ("zapiszPTestoweInfluxDB: temperaturze powietrza - ok")
            end   
            tmr.stop(4)
            tmr.start(3)
        end)
    end
    if licznikInfluxDB == 1 then
        licznikInfluxDB = licznikInfluxDB + 1
        tmr.stop (3)
        tmr.alarm(4, 1000, tmr.ALARM_AUTO, function()
            if zapiszInfluxDB ("test", "pGraniczne,pm1=" ..pTestowe.pm1 .. "." .. pTestowe.pm1_u
            .." pm10=" ..pTestowe.pm10 .. "." .. pTestowe.pm10_u) ~= 204 then
                if debugowanie then
                    print ("zapiszPTestoweInfluxDB: Coś poszło nie tak przy pm1")
                end
            end
            tmr.stop(4)
            tmr.start(3)
        end)
    end
    if licznikInfluxDB == 2 then
        licznikInfluxDB = licznikInfluxDB + 1
        tmr.stop (3)
        tmr.alarm(4, 1000, tmr.ALARM_AUTO, function()
            if zapiszInfluxDB ("test", "pGraniczne,pm25=" ..pTestowe.pm25 .. "." .. pTestowe.pm25_u
            .." pressure=" ..pTestowe.pressure .. "." .. pTestowe.pressure_u) ~= 204 then
                if debugowanie then
                    print ("zapiszPTestoweInfluxDB: Coś poszło nie tak przy pm25 " .. c)
                end
            end
            tmr.stop(4)
            tmr.start(3)
        end)
    end
    if licznikInfluxDB == 3 then
        licznikInfluxDB = licznikInfluxDB + 1
        tmr.stop (3)
        tmr.alarm(4, 1000, tmr.ALARM_AUTO, function()
    if zapiszInfluxDB ("test", "V,Vc=" .. pTestowe.Vc .." Vp=" ..pTestowe.Vp) ~= 204 then
        if debugowanie then
            print ("zapiszPTestoweInfluxDB: Coś poszło nie tak przy Vc")
        end
    end
            tmr.stop(4)
            tmr.start(3)
        end)
    end
    if licznikInfluxDB == 4 then
        licznikInfluxDB = licznikInfluxDB + 1
        tmr.stop (3)
        tmr.alarm(4, 1000, tmr.ALARM_AUTO, function()
    if zapiszInfluxDB ("test", "humidity,humidityMax=" .. pCz.humidityMax .." humidityMin=" .. pCz.humidityMin) ~= 204 then
        if debugowanie then
            print ("zapiszPTestoweInfluxDB: Coś poszło nie tak przy humidity")
        end
    end
            tmr.stop(4)
            tmr.start(3)
        end)
    end
    if licznikInfluxDB == 5 then
        licznikInfluxDB = licznikInfluxDB + 1
        tmr.stop (3)
        tmr.alarm(4, 1000, tmr.ALARM_AUTO, function()
            if zapiszInfluxDB ("test", "humidity,humidity=" .. pTestowe.humidity .." humidityOpt=" .. pCz.humidityOpt) ~= 204 then
                if debugowanie then
                    print ("zapiszPTestoweInfluxDB: Coś poszło nie tak przy humidity opt")
                end
            end
            tmr.stop(4)
            tmr.start(3)
        end)
    end            
    local logicznyZapisPoziomuWody = 0
    if pTestowe.poziomWody then
        logicznyZapisPoziomuWody = 1
    else
        logicznyZapisPoziomuWody = 0
    end
    tmr.stop (3)
    local wp = zapiszInfluxDB ("test", "pGraniczne,poziomWody=" .. logicznyZapisPoziomuWody ..' kom="czujnik wylaczony"')
    tmr.alarm(4, 1000, tmr.ALARM_AUTO, function() 
        if wp ~= 204 then
            if debugowanie then
                print ("zapiszPTestoweInfluxDB: Coś poszło nie tak przy poziomie wody...")
            end
        end
        tmr.stop(4)
        licznikInfluxDB = 0 
    end)
end

gpio.write (pin, LED_OFF)
