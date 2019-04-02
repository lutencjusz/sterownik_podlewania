-- wynik = ""
-- czyZsynchonizowano = false
-- pTestowe= {}

function tempFloatNaIntAirapi (s, t) -- wyszukuje liczbe float i zmianienia ja na dwie
-- s - string do przeszukania
-- t - zmienna do znalezienia (dokładnie 13 znakow)

    local ea = string.find(s, t)
    local da = string.sub(s, ea+14)
    -- print ("da: " .. da)
    local e1a = string.find(da, ',')
        if e1a == nil then
        e1a = string.find(da, '}') + 1 -- korekta, po przecinku pobiera dwie liczby
    end
    local d1a = string.sub(da, 1, e1a-2)
    -- print ("d1a: " .. d1a)
    -- print ("s: " .. s .. ";e1: " .. e1)
    c1, d1 = string.match(d1a, "(%d+).(%d+)")
    if debugowanie then
        print ("c1: " .. c1 .. ";d1: " .. d1)
    end
    return c1+0, d1+0
end

function znajdzDanePogodoweJSON(s)
-- s - cały komunikat do wyszukania JSON 
    local s1 = ""
    local g = string.find(s, 'current')
    local g1 = string.find(s, 'history')
    if g ~= nil and g1 ~= nil then
        s1 = string.sub(s, g, g1)
    else
        return nil
    end    
    local e = string.find(s1, 'values')
    local e1 = string.find(s1, "indexes")
    if e ~= nil and e1 ~= nil then
        return string.sub(s1, e+8, e1-3)
    else
        return nil
    end
end

function pobierzDanePowietrza()
    -- wynikPZ = nil -- inicjacja danych
    print(" Wczytuje dane testowe z serwisu airapi.airly.eu...")
    local host = "airapi.airly.eu"
    -- local headers = 'apikey: WZDiLQVB5GkGODEV5aX3WWA6rko5zn8f\r\n', 
    -- 'Accept: application/json\r\n'
    -- local path = "/v2/measurements/point?&lat=50.062006&lng=19.940984"
    local path = "/v2/measurements/installation?installationId=6532"
    local url = "https://" .. host .. path;
    local srv = tls.createConnection(net.TCP, 0)
    srv:on("receive", function(code, data)
            d2 = znajdzDanePogodoweJSON(data)
            if d2 ~= nil then   
                wynikPZ = d2
                if debugowanie then
                    print ("z pobierzDanePowietrza() wynikPZ= " .. wynikPZ)
                end
                dataOstatniegoZapisu = podajCzas()
                host = nil; path = nil; url = nil; srv = nil
                collectgarbage()
            else
                if dataNieudanejProby == nil then
                     dataNieudanejProby = podajCzas()
                end
            end
    end)
    srv:on("connection", function(sck, c)
        sck:send("GET " .. path .. " HTTP/1.1\r\nAccept: application/json\r\napikey: WZDiLQVB5GkGODEV5aX3WWA6rko5zn8f\r\nHost: " .. host .. "\r\nConnection: close\r\nAccept: */*\r\n\r\n")
    end)
  srv:connect(443, host)
end


function odswierzDanePowietrza()
    if wynikPZ ~= nil then
            pTestowe.pm1, pTestowe.pm1_u = tempFloatNaIntAirapi (wynikPZ, '"PM1')
            pTestowe.pm25, pTestowe.pm25_u = tempFloatNaIntAirapi (wynikPZ, "PM25")
            pTestowe.pm10, pTestowe.pm10_u = tempFloatNaIntAirapi (wynikPZ, '"PM10')          
            pTestowe.humidity, pTestowe.humidity_u = tempFloatNaIntAirapi (wynikPZ, "DITY")
            pTestowe.temp, pTestowe.temp_u = tempFloatNaIntAirapi (wynikPZ, "TURE")
            pTestowe.pressure, pTestowe.pressure_u = tempFloatNaIntAirapi (wynikPZ, "SURE")
            if dataOstatniegoZapisu ~= nil then
                pTestowe.dataPomiaru = dataOstatniegoZapisu
            elseif czyZsynchonizowano then
                pTestowe.dataPomiaru = podajCzas()
            else
                pTestowe.dataPomiaru = "01/01/2019 00:00:01"
            end
            pTestowe.Vc, pTestowe.Vc_u = parsowanieVc ()
            pTestowe.Vp = 12
            pTestowe.poziomWody = true -- ustawianie czujnika wody - true - jest woda
            if debugowanie then
                print ("    pTestowe z odswierzDanePowietrza()")
                print (sjson.encode(pTestowe))
            end
            if debugowanie then
                print ("temp: " .. pTestowe.temp .. ','.. pTestowe.temp_u)
                print ("PM1: " .. pTestowe.pm1 .. ',' .. pTestowe.pm1_u)
                print ("PM10: " .. pTestowe.pm10 .. ',' .. pTestowe.pm10_u)
                print ("PM25: " .. pTestowe.pm25 .. ',' .. pTestowe.pm25_u)
                print ("wilgotnosc: " .. pTestowe.humidity .. ',' .. pTestowe.humidity_u)
                print ("cisnienie: " .. pTestowe.pressure .. ',' .. pTestowe.pressure_u)
            end
            host = nil; path = nil; url = nil
            collectgarbage()
    else
        print ("Nie odswierzylem danych powietrza!")
        if dataNieudanejProby ~= nil then
            local ileCzasuMinelo = odlegloscDaty(dataNieudanejProby, podajCzas())
            if ileCzasuMinelo > czasDoOdswierzeniaMax then
                o = "Upłynelo " .. ileCzasuMinelo .. "min. > (czasDoOdswierzeniaMax: " .. czasDoOdswierzeniaMax .. "). Restartuje sterownik!"
                n = "Restart sterownika z powodu braku odswierzenia"
                k = "r1"
                p = 1
                zapiszAlarmyDoPliku(1, n, o, "alert.json", k)
                print("odswierzDanePowietrza() " .. n)
                node.restart()
            end 
        end
    end
end

