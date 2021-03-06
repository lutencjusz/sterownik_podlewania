gpio.write (pin, LED_ON)
-- wczytanie paramtrów sieci WiFi z pliku ustawienia.json
key = "abcdef0987654321" -- klucz musi sie składać z 16 znakow

station_cfg={}
station_cfg.ssid=u.ssid
station_cfg.pwd=crypto.decrypt("AES-ECB", key, encoder.fromHex(u.pass))
-- station_cfg.ssid='HUAWEI P20 lite'
-- station_cfg.pwd='Aleks07$'
station_cfg.save=true
wifi.sta.config(station_cfg)

  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTATUS: GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
 T.netmask.."\n\tGateway IP: "..T.gateway)
 u.IP = T.IP -- serverIP musi być utworzony w init.lua
 end)

print("Oczekuje na przydzielenie IP...")

tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() ~= nil then 
        tmr.stop(0)
        print ("Uruchomiono synch. czasu...")  
        sntp.setoffset(1) -- czas letni
        sntp.sync(nil, nil, nil, 1)
    end
end)

function podajCzas ()
    tm = rtctime.epoch2cal(rtctime.get())
    if u.offsetCzasLetni == 0 then
        gl = tm["hour"]
    else           
        gl = tm["hour"]+u.offsetCzasLetni
    end
    return string.format("%02d/%02d/%04d %02d:%02d:%02d", tm["day"], tm["mon"], tm["year"], gl, tm["min"], tm["sec"])
end

function zakoduj(d)
print (encoder.toHex(crypto.encrypt("AES-ECB", key, d)))
end

tmr.alarm(1, 5000, tmr.ALARM_AUTO, function()
    tm = rtctime.epoch2cal(rtctime.get())
    if  tm["year"]~=1970 then
        tmr.stop(1)
        print ("Czas zsynchronizowano.")
        czyZsynchonizowano = true -- zmienna globalna zainicjowana w init.lua
        if u.offsetCzasLetni == nil then
            gl = tm["hour"]
        else
            gl = tm["hour"]+u.offsetCzasLetni
        end
        print(string.format("%02d/%02d/%04d %02d:%02d:%02d", tm["day"], tm["mon"], tm["year"], gl, tm["min"], tm["sec"]))
        tm=nil; gl=nil
        collectgarbage()
        gpio.write (pin, LED_OFF)
    end
end) 
