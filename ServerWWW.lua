-- informacja o aktualnym systemie
function systemInfo(text)
    majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()
    heap = node.heap()
    remaining, used, total = file.fsinfo()
    print(text)
    print("zajetosc pamieci: "..41000-heap.." B, (wolne: "..heap.." B)")
    print("zajetosc plikow: "..used.." B, (wolne: "..remaining.." B)")
end

local function pobierzAktualneDaneZCzujnikow()
-- wymaga wczytania modułu logika
    odswierzDanePowietrza()
    return pTestowe -- parametr z modułu logika
end

function dodajAktualneDaneDoPliku(nazwaPliku)
-- dodatkowo potrzebuje:
--  maxIloscWierszyLog
--  minIloscWierszyLog
--    local dCz = pobierzAktualneDaneZCzujnikow()

    if file.exists(nazwaPliku) then
        local iloscWierszyLog = 0;
        iloscWierszyLog = ileWierszyWPliku (nazwaPliku)
        if iloscWierszyLog > maxIloscWierszyLog then
            przepiszPliki (nazwaPliku, "tmp.json", minIloscWierszyLog, iloscWierszyLog)
        end
        if file.open(nazwaPliku, "a+") and pTestowe ~= nil then
            -- print (pTestowe)
            pTestoweJSON = sjson.encode(pTestowe)
            print ("pTestoweJSON = " .. pTestoweJSON)
            local data = ","..pTestoweJSON.."\n"
            file.write(data)
            file.close()
            -- print ("Nowy plik "..data)
        else
            print ("Nie wczytano lub zapisano pliku: "..nazwaPliku)
            return "" 
        end
    else
        if file.open(nazwaPliku, "w") then 
            local data = sjson.encode(pTestowe).."\n"
            file.write(data)
            file.close()
            -- print ("Dodaje "..data)
        end
    end
    systemInfo("/dadaj max")
    file=nil; data=nil;
    collectgarbage()
    return aktualnaIloscWierszyLog
end

function uruchomPompki(res)
    ob = {}
    ob.naglowek = ''
    ob.opis = ''
    ob.klucz = ''
    ob.prior = 3
    ob.status = true
    local tA = nil -- tablica atertow
    if tAlert ~= "" then -- jeśli jest plik to tworzy tablice alertow
        local decTAlertJSON = sjson.decoder()
        if decTAlertJSON:write ("[" .. tAlert .. "]") == nil then
            print ("Blad przy zamianie tAlert na JSON w uruchomPompki! Usuwam alert.json")
            usunPlik("alert.json")
        else
            tA = decTAlertJSON:result()
        end    
        -- tA = sjson.decode("[" .. tAlert .. "]")
    end
    if czyMiesciSiePrzedzialeCzasowym () then
        ob = ustawienieAlertowLogiki (ob) 
        if debugowanie then
            print ("        Parametry logiki w uruchomPompki(res):")
            print (ob.naglowek, ob.opis, ob.status, ob.prior, ob.klucz)
        end
        if ob.status then
            dodajAktualneDaneDoPliku("log.json")
            czyWyslanoMejl = false -- zerowanie przypomnienia mejlowego z modułu logika
            if ob.naglowek ~= "" then
                print ("        zapis do pliku logu i alarmu z uruchomieniem pompek i wyslaniem mejla...")
                local subject = "Sterownik podlewania uruchomił pompki"
                local body = "Wlasnie podlalem kwiatki. Uzupelnij wode..."
                send_email(subject,body)
                if tA ~= nil and ob.klucz == tA[#tA].klucz then
                    zapiszAlarmyDoPliku(3, "taki sam", "", "alert.json", ob.klucz)
                else
                    zapiszAlarmyDoPliku(3, ob.naglowek, ob.opis, "alert.json", ob.klucz)
                end
            else
                print ("        nie ma co zapisac do pliku alertu z uruchom pompki...")
            end
        else
            print ("        zapis do pliku alarmu bez uruchomienia pompek...")
            if tA ~= nil and ob.klucz == tA[#tA].klucz then   
                zapiszAlarmyDoPliku(ob.prior, "taki sam", "", "alert.json", ob.klucz)
            else
                zapiszAlarmyDoPliku(ob.prior, ob.naglowek, ob.opis, "alert.json", ob.klucz)
            end
            if res then
                local data = sjson.encode(konwerujAlertNaObiekt (ob.prior, ob.naglowek, ob.opis, ob.klucz))
                res:send(data)
            end
        end
        -- initKalendarza() -- żeby odświerzyć dane
    else
        if res then
            local data = sjson.encode(konwerujAlertNaObiekt (ob.prior, "do uruchomienia zostalo:" .. podajCzasS((zaIleUruchomicPompkiKalendarz() - ileCzasuDoWyslaniaMejla)) .. " .min", ob.opis, ob.klucz))
            res:send(data)
        end
    end
end

httpServer:use('/wszystko', function(req, res)
    res:type('application/json')
    wyslijPlik("log.json", res)
    systemInfo("/wszystko")
end)

httpServer:use('/wszystkieAlerty', function(req, res)
    res:type('application/json')
    wyslijPlik("alert.json", res)
    systemInfo("/wszystkieAlerty")
end)

httpServer:use('/aktualne', function(req, res)
    res:type('application/json')
    local data = "[\n"..sjson.encode(pobierzAktualneDaneZCzujnikow()).."]\n"
    res:send(data)
    systemInfo("/aktualne")
end)

httpServer:use('/aktualnyStatus', function(req, res)
    ob = {}
    ob.naglowek = ''
    ob.opis = ''
    ob.klucz = ''
    ob.prior = 3
    ob.status = true
    res:type('application/json')
    ob = ustawienieAlertowLogiki (ob) 
    local data = sjson.encode(konwerujAlertNaObiekt (ob.prior, ob.naglowek, ob.opis, ob.klucz)).."\n"
    res:send(data)
    systemInfo("/aktualnyStatus")
end)

httpServer:use('/dodajAktualne', function(req, res)
    res:type('application/json')
    iloscWierszyLog = dodajAktualneDaneDoPliku("log.json")
    local data = "[\n"..sjson.encode(pobierzAktualneDaneZCzujnikow()).."]\n"
    res:send(data)        
end)

httpServer:use('/dodajAlert', function(req, res)
    res:type('application/json')
    zapiszAlarmyDoPliku(3, "Naglowek alertu", "Opis alertu", "alert.json")
    local data = "[\n"..sjson.encode(konwerujAlertNaObiekt (3, "Naglowek alertu", "Opis alertu")).."]\n"
    res:send(data)        
end)

httpServer:use('/usunLog', function(req, res)
    res:type('application/json')
    usunPlik("log.json")
    local data = "[]"
    res:send(data)
    systemInfo("/usunLog")
end)

httpServer:use('/usunAlerty', function(req, res)
    res:type('application/json')
    usunPlik("alert.json")
    local data = "[]"
    res:send(data)
    systemInfo("/usunAlerty")
end)

httpServer:use('/parametry', function(req, res)
    res:type('application/json')
    local data = sjson.encode(pCz)
    res:send(data)
    systemInfo("/parametry")
end)

httpServer:use('/pobierzAktualneDane', function(req, res)
    pobierzDanePowietrza()
    local data = "[\n"..sjson.encode(pobierzAktualneDaneZCzujnikow()).."]\n"
    res:send(data)
    systemInfo("/pobierzAktualneDane")    
end)

httpServer:use('/restart', function(req, res)
    print ("Restart!")
    res:type('application/json')
    res:send('{"status":"restart na zadanie uzytkonika"}')
    node.restart()   
end)

httpServer:use('/LED0=ON', function(req, res)
    gpio.mode(0, gpio.OUTPUT)
    gpio.write (0, 0)
    print ("LED0=ON")
    res:type('application/json')
    res:send('{"status":"ON"}')
end)

httpServer:use('/LED0=OFF', function(req, res)
    gpio.mode(0, gpio.OUTPUT)
    gpio.write (0, 1)
    print ("LED0=OFF")
    res:type('application/json')
    res:send('{"status":"OFF"}')
end)

httpServer:use('/LED4=ON', function(req, res)
    gpio.mode(4, gpio.OUTPUT)
    gpio.write (4, 0)
    print ("LED4=ON")
    res:type('application/json')
    res:send('{"status":"ON"}')
end)

httpServer:use('/LED4=OFF', function(req, res)
    gpio.mode(4, gpio.OUTPUT)
    gpio.write (4, 1)
    print ("LED4=OFF")
    res:type('application/json')
    res:send('{"status":"OFF"}')
end)

httpServer:use('/uruchomPompki', function(req, res)
    uruchomPompki(res)
    systemInfo("/uruchomPompki")
end)

httpServer:use('/kiedyNastepneSprawdzenie', function(req, res)
    local g = 0
    local m = 0
    local p
    local k1G = 0
    local k1M = 0
    local k2G = 0
    local k2M = 0
    local zI = 0
    local dataZI = ""
    res:type('application/json')
    if dataNastepnegoSprawdzenia == "" then
        res:send('{"status":"Jeszcze nie było pomiaru"}')
    else
        local czasMin = odlegloscDaty(podajCzas(), dataNastepnegoSprawdzenia)
        if czasMin >= 60 then
            g = czasMin / 60
            m = czasMin - (g * 60)
        else
            m = czasMin
        end
    end
    k1G, k1M = parsowanieCzasu(tKalendarz[1])
    k2G, k2M = parsowanieCzasu(tKalendarz[2])
    zI, dataZI = zaIleUruchomicPompkiKalendarz()
    local data = '{"status":"' .. dataNastepnegoSprawdzenia 
    .. '","godz":' .. g 
    ..',"min":' .. m
    ..',"czasKalendarz1Godz":' .. k1G
    ..',"czasKalendarz1Min":' .. k1M 
    ..',"czasKalendarz2Godz":' .. k2G 
    ..',"czasKalendarz2Min":' .. k2M 
    ..',"mozliwyCzasNaPodlewanie":' .. mozliwyCzasNaPodlewanie
    ..',"zaIleUruchPompki":' .. zI
    ..',"dataUruchPompek":"' .. dataZI
    .. '"}'
    res:send(data)
    systemInfo("/kiedyNastepneSprawdzenie")
end)

httpServer:use('/', function(req, res)
    local data = "<h1>Serwis Sterownika do podlewania kwiatkow na balkonie</h1>"
    .."<p>by Lutencjusz</p>"
    .."<h3>---------------------</h3>"
    .."nastepujace funkcjonalnosi mozna uruchomic po rozszerzeniu:"
    .."<LI>/wszystko - wszystkie wpisy logow"
    .."<LI>/wszystkieAlerty - wszystkie wpisy alertow"
    .."<LI>/aktualne - pobranie i przekazanie wskaźnikow"
    .."<LI>/aktualnyStatus - pokazuje status podlewania"
    .."<LI>/dodajAktualne - dodaje aktualne wskazniki do logow (w celach testowych)"
    .."<LI>/dodajAlert -dodaje przykladowy alert do alertow (w celach testowych)"
    .."<LI>/usunLog - usuwa plik logow"
    .."<LI>/usunAlerty - usuwa plik alertow"
    .."<LI>/uruchomPompki - sprawdza i uruchamia pompki. Uwagi zapisuje w plikach logow i alertow"
    .."<LI>/parametry - przesyła parametry graniczne układu"
    .."<LI>/kiedyNastepneSprawdzenie - podaje date następnego sprawdzenia, czy uruchomic pompke"
    .."<LI>/pobierzAktualneDane - pobiera aktualne dane z zewnetrznych systemow"
    .."<LI>/restart - restartuje sterownik"
    .."<LI>/LED0=ON - uruchamia pompke 1"
    .."<LI>/LED0=OFF - wylacza pompke 1"
    .."<LI>/LED4=ON - uruchamia pompke 2"
    .."<LI>/LED4=OFF - wylacza pompke 2</OL>" 
    res:send(data)
end)

httpServer:listen(80)
print ("Uruchomienie serwera WWW")

