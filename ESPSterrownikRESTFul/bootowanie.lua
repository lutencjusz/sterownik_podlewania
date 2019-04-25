print("Usuwanie zbednych plikow...")
l = file.list();
for k,v in pairs(l) do
    if (string.find(k, ".lua")~=nil and string.find(k, "init.lua")==nil) or string.find(k, ".img")~=nil or string.find(k, ".lc")~=nil then 
        if file.exists(k) then -- czy trzeba kompilować moduł
            -- s = string.gsub(k, ".lua", ".lc")
            file.remove(k)
            print("  usunieto " .. k .. " ...")
            -- node.compile(k)
            -- file.remove(k)
            -- print ("Skompilowano "..k)
        end
    end
end
l=nil; k=nil; v=nil; s=nil
collectgarbage() 

-- ustawienie zmiennych środowiskowych
print("Wczytuje ustawienia WiFi...")

plik = file.open ("ustawieniaZ.json","r")
if plik == nil then
    print ("Nie znalazlem pliku ustawien sieciowych: ustawieniaZ.json")
end
--print (plik)
l=plik:read()
file.close()
if debugowanie then
    print(l)
end
u = sjson.decode(l)

LED_ON = u.LED_ON
LED_OFF = u.LED_OFF
pin = u.pin -- pin do swiecenia

gpio.mode(pin, gpio.OUTPUT)
gpio.write (pin, LED_ON) -- zapalenie diody kontrolnej

maxIloscWierszyLog = u.maxIloscWierszyLog
minIloscWierszyLog = u.minIloscWierszyLog
czasDoOdswierzeniaMax = u.czasDoOdswierzeniaMax
czasDoOdswierzeniaMin = u.czasDoOdswierzeniaMin

maxIloscWierszyAlert = u.maxIloscWierszyAlert
minIloscWierszyAlert = u.minIloscWierszyAlert
ileCzasuDoWyslaniaMejla = u.ileCzasuDoWyslaniaMejla -- w minutach

mozliwyCzasNaPodlewanie = u.mozliwyCzasNaPodlewanie -- w godzinach

dataNastepnegoSprawdzenia = ""
dataNieudanejProby = nil
dataOstatniegoZapisu = nil

czyZsynchonizowano = false
czyWyslanoMejl = false
czyUruchomicPompkiKalendarz1 = true
pTestowe = {}
wynikPZ = nil -- wynik z parametrypo
count = 0 -- ustawienie licznika inicjacji
countObslugi = 0 -- ustawienie licznika obslugi

function do_next()  -- do prowadzenia dialogu z serwerem
    if(count == 0)then  
        count = count+1
        tmr.stop(3)
        pcall(function()node.flashindex("vc")()end)
        print ("Wczytano modul Vc...")
        pcall(function()node.flashindex("pliki")()end)
        print ("Wczytano modul pliki...")
        pcall(function()node.flashindex("WiFi")()end)
        tmr.alarm(4, 1000, tmr.ALARM_AUTO, function()
            if czyZsynchonizowano then
                tmr.stop(4)
                tmr.start(3)
            end
        end)
    elseif(count==1) then
        count = count+1
        tmr.stop(3)
        if file.exists('mejl.json') then
            pcall(function()node.flashindex("wyslijMail")()end)
            print ("Wczytano modul wyslijMail...")
            send_email()
            tmr.alarm(4, 2000, tmr.ALARM_AUTO, function()
                if not file.exists('mejl.json') then
                    tmr.stop(4)
                    tmr.start(3)
                end
            end)
        else
            print ("Nie wczytano modulu wyslijMail... nie ma co wysylac")
            tmr.start(3)
        end
    elseif(count==2) then
        count = count+1
        tmr.stop(3)
        pcall(function()node.flashindex("parametryZewn")()end)
        print ("Wczytano modul parametryZewn i ladowanie pTestowe...")
        gpio.write (pin, LED_ON) -- zapalenie diody kontrolnej
        pobierzDanePowietrza()--pierwsze załadowanie danych pTestowe
        dataOstatniegoZapisu = podajCzas() -- zostało wprowadzone do pobierzDanePowietrza()
        licznikPZ = 0
        tmr.alarm(4, 2000, tmr.ALARM_AUTO, function() -- powtarza trzy razy
            if wynikPZ ~= nil or licznikPZ > 3 then
                if wynikPZ == nil then
                    print ("Nie udalo sie pobrac danych podczas bootowania... restartuje sterownik")
                    node.restart()
                end  
                odswierzDanePowietrza()
                tmr.stop(4)
                tmr.start(3)
                gpio.write (pin, LED_OFF) -- zapalenie diody kontrolnej
            else
                licznikPZ = licznikPZ + 1
            end
        end)
    elseif(count==3) then
        count = count+1
        tmr.stop(3)
        pcall(function()node.flashindex("_init")()end)
        httpServer:listen(80)
        print ("Uruchomienie serwera WWW")
        odswierzZakresyCzujnikow()
        print ("Wczytano modul _init. \nSterownik gotowy do dzialania...")
        gpio.write (pin, LED_OFF)
        tmr.alarm(5, 1000, tmr.ALARM_AUTO, obslugaModulu)
        -- uruchomienie sprawdzen
        tmr.unregister(3)
        tmr.unregister(4)
        collectgarbage()              
    end
end

function obslugaModulu()
    -- print ("countOblugi= " .. countObslugi)
    if(countObslugi == 0) then
        countObslugi = countObslugi + 1
        tmr.stop(5) -- zatrzymanie aż do uruchomienia po butowaniu
        tmr.interval(5, 1000) -- zmiana na obsługę klienta
        print ("Uruchomiono cykliczna obsluge - tmr.alarm(5)...")
        if debugowanie then
            print("     Data ostatniego zapisu: " .. dataOstatniegoZapisu)
            print("     podaj czas: " .. podajCzas())
            print("     Czas do odswierzenia w min: " .. czasDoOdswierzeniaMax)
        end
        if odlegloscDaty (dataOstatniegoZapisu, podajCzas())> czasDoOdswierzeniaMin then
            pobierzDanePowietrza() --pierwsze załadowanie danych pTestowe
            licznikPZ = 0
            tmr.alarm(6, 2000, tmr.ALARM_AUTO, function()
                if wynikPZ ~= nil or licznikPZ > 10 then
                    odswierzDanePowietrza()
                    tmr.stop(6)
                    tmr.start(5)
                else
                    licznikPZ = licznikPZ + 1
                end   
            end)
        else
            tmr.start(5)
        end
        if odlegloscDaty (dataOstatniegoZapisu, podajCzas())> czasDoOdswierzeniaMax then
            print ("Trzeba odswierzyc dane... restart.")
            node.restart()
        else
            print ("Dane aktualne, nie trzeba odswierzac...")
        end   
    elseif(countObslugi==1) then
        countObslugi = countObslugi + 1 
        tmr.stop(5)    
        initKalendarza() -- wczytanie najnowszych log i kalendarza
        print ("    Uruchomiono kalendarz...")
        if zapisDoInfluxDB then
            zapiszPTestoweInfluxDB()
            print ("    Uruchomiono InfluxDB...")
            tmr.alarm(6, 1000, tmr.ALARM_AUTO, function()
                if tLog ~= nil then
                    tmr.stop(6)
                    tmr.start(5)
                end
            end)
         else
            print ("    Nie uruchomilem InfluxDB...")
            tmr.start(5)
         end
    elseif(countObslugi==2) then
        countObslugi = countObslugi + 1 
        tmr.stop(5)
        print ("    Ustawienie porannego podlewania...")
        if pTestowe.humidity > pCz.humidityOpt then
            czyUruchomicPompkiKalendarz1 = false
            print("     Wylaczam poranne podlewanie.")
            print("     Jest zbyt wilgotno (" .. pTestowe.humidity .. ") > Wilgotnosci optymalnej(" .. pCz.humidityOpt)
        end
        print ("    Uruchomiono pompki...")
        uruchomPompki()
        print ("    Uruchomiono initKalendarz...")
        initKalendarza()
        -- print ("    tLog = " .. tLog)
        tmr.alarm(6, 1000, tmr.ALARM_AUTO, function()
            if tLog ~= nil then
                tmr.stop(6)
                tmr.start(5)
            end
        end)
    elseif(countObslugi==3) then
        countObslugi = countObslugi + 1 
        tmr.stop(5)
        if debugowanie then
            print("     Sprawdzenie za ile uruchomic...")
        end
        zaIle, nData = zaIleUruchomicPompkiKalendarz()
        d = (zaIle - ileCzasuDoWyslaniaMejla)
        if debugowanie then 
            print ('d= ' .. d)
        end
        if d < 0 then
            d = d + ileCzasuDoWyslaniaMejla
        end 
        if d > 113 or d < 0 then 
        -- ustawienie gornej granicy lub gdy następne sprawdzenie
            d = 113
        end
        if d > czasDoOdswierzeniaMax then
            d = czasDoOdswierzeniaMax + 1;
        end
        if debugowanie then       
            print ('uruchomienie sprawdzenia za' .. podajCzasS(d) .. '(' .. nData .. ')')
            print ('    tmr.int 5: ' .. d * 60 * 1000)
        end
        tmr.interval(5, d * 60 * 1000) -- ustawienie następnego uruchomienia
        dataNastepnegoSprawdzenia = kiedyNastepneSprawdzenie (d)
        tmr.start(5)
        countObslugi = 0 -- wyzerowanie cyklu obsługi
        tmr.unregister(6)
        collectgarbage()
        -- if odlegloscDaty (dataNieudanejProby, podajCzas())> czasDoOdswierzeniaMax then
        --    node.restart()
        -- end
    end 
end

tmr.alarm(3,1000,1,do_next)
