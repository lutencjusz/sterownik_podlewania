-- wymaga modułu WiFi
-- wymaga modułu pliki
-- gpio.write (pin, LED_ON)
-- tKalendarz = {}
-- tLog = {}

function initKalendarza()
    tKalendarz = odczytajKalendarzZPliku ("kalendarz.json")
    tLog = wczytajPlikDoZmiennej("log.json")
    tAlert = wczytajPlikDoZmiennej("alert.json")
end

function wartCzasu (g, m)
    return g*60+m
end

function odlegloscCzasu (s1, s2) -- w minutach
    return wartCzasu (parsowanieCzasu(s2)) - wartCzasu (parsowanieCzasu(s1))
end

function parsowanieCzasu (sA)
    local gA = 0
    local mA = 0
    gA, mA = string.match(sA, "(%d+):(%d+)")
    
    return tonumber(gA), tonumber(mA)
end

function parsowanieDaty (dA)
    dA, miA, rA, gA, mA, sA = string.match(dA, "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)")
    return tonumber(dA), tonumber(miA), tonumber(rA), tonumber(gA), tonumber(mA), tonumber(sA)
end

function wartDaty (dA, miA, rA, gA, mA, sA)
    return 24*60*dA + 60*gA + mA
end

function odlegloscDaty (d1, d2) -- w minutach
    return wartDaty (parsowanieDaty(d2)) - wartDaty (parsowanieDaty(d1))
end

function konwersjaDateNaS(dA, miA, rA, gA, mA, sA)
    return string.format("%02d/%02d/%04d %02d:%02d:%02d", dA, miA, rA, gA, mA, sA)
end

function konwersjaCzasNaData (c)
-- wymaga modułu WiFi
    dA, miA, rA, gA, mA, sA = parsowanieDaty(podajCzas())
    gB, mB = parsowanieCzasu(c)
    return konwersjaDateNaS(dA, miA, rA, gB, mB, 0)
end

function konwersjaCzasNaDataGodzina (c)
-- wymaga modułu WiFi
    dA, miA, rA, gA, mA, sA = parsowanieDaty(podajCzas())
    gB, mB = parsowanieCzasu(c)
    return konwersjaDateNaS(dA, miA, rA, gB + mozliwyCzasNaPodlewanie, mB, 0) -- dodaje godzine
end

function konwersjaCzasNaDataPrzyszla (c)
    dA, miA, rA, gA, mA, sA = parsowanieDaty(podajCzas())
    gB, mB = parsowanieCzasu(c)
    return konwersjaDateNaS(dA+1, miA, rA, gB, mB, 0)
end

function podajCzasZnormalizowany(czasMin)
    if czasMin >= 60 then
        local g = czasMin / 60
        local m = czasMin - (g * 60)
        return string.format("%2d:%2d", g, m)
    end
    return string.format("0:%2d", czasMin)
end

function kiedyNastepneSprawdzenie (n)
    local sk = 0
    local gk = 0
    local mk = 0
    local dk = 0
    dkA, mikA, rkA, gkA, mkA, skA = parsowanieDaty(podajCzas())
    gkB, mkB = parsowanieCzasu(podajCzasZnormalizowany(n))
    sk = skA
    if mkA + mkB >= 60 then
        gk = 1
        mk = mkA + mkB - 60
    else
        mk = mkA + mkB
    end
    if gkA + gkB + gk >= 24 then
        dk = dkA + 1
        gk = gk + gkB + gkA - 24
    else
        dk = dkA
        gk = gk + gkA + gkB
    end 
    return konwersjaDateNaS(dk, miA, rA, gk, mk, sk)
end

function zapiszKalendarzDoPliku(nazwaPliku, k)
    s = sjson.encode(k)
    if file.open(nazwaPliku, "w") then 
        local line=file.write(s)
        file.close()
    else
        print ("Nie zapisano kalendarza do pliku: "..nazwaPliku)
    end
    file=nil; line=nil
    collectgarbage()
end

function odczytajKalendarzZPliku (nazwaPliku)
-- wymaga modułu pliki
    return sjson.decode(wczytajPlikDoZmiennej(nazwaPliku))
end

function podajCzasS(czasSek)
    if czasSek > 60 then
        local g = czasSek / 60
        local m = czasSek - (g * 60)
        return string.format("%2d godz. %2d min.", g, m)
    end
    return string.format("%3d min.", czasSek)
end

function zaIleUruchomicPompkiKalendarz()
    local decTLogJSON = sjson.decoder()
    if decTLogJSON:write ("[" .. tLog .. "]") == nil then
        print ("Blad przy zamianie tLog na JSON w uruchomPompki!")
        return 1
    else
        l = decTLogJSON:result()
        if czyUruchomicPompkiKalendarz1 and odlegloscDaty(podajCzas(), konwersjaCzasNaData(tKalendarz[1]))>0 then
            return odlegloscDaty(podajCzas(), konwersjaCzasNaData(tKalendarz[1])), konwersjaCzasNaData(tKalendarz[1])
        else
            if odlegloscDaty(podajCzas(), konwersjaCzasNaData(tKalendarz[2]))>0 then
                return odlegloscDaty(podajCzas(), konwersjaCzasNaData(tKalendarz[2])), konwersjaCzasNaData(tKalendarz[2])
            else
                if czyUruchomicPompkiKalendarz1 then
                    return odlegloscDaty(podajCzas(), konwersjaCzasNaDataPrzyszla(tKalendarz[1])), konwersjaCzasNaDataPrzyszla(tKalendarz[1])           
                else
                    return odlegloscDaty(podajCzas(), konwersjaCzasNaDataPrzyszla(tKalendarz[2])), konwersjaCzasNaDataPrzyszla(tKalendarz[2])
                end
            end
        end
    end 
end

function czyMiesciSiePrzedzialeCzasowym ()
    local czasKalendarz1 = odlegloscDaty(podajCzas(), konwersjaCzasNaData(tKalendarz[1]))
    local czasKalendarz2 = odlegloscDaty(podajCzas(), konwersjaCzasNaData(tKalendarz[2]))
    if debugowanie then
        print ("        Odelgłości od czasow kalendarzowych:")
        print ("         - przedzial dla czasKalendarz1 =(" .. czasKalendarz1 .. " - " .. czasKalendarz1 + mozliwyCzasNaPodlewanie * 60 .. ")")
    print ("         - przedzial dla czasKalendarz2 =(" .. czasKalendarz2 .. " - " .. czasKalendarz2 + mozliwyCzasNaPodlewanie * 60 .. ")")
    end
    if czyUruchomicPompkiKalendarz1 and czasKalendarz1 < 5 and czasKalendarz1 + mozliwyCzasNaPodlewanie * 60 >= 0 then
        return true
    elseif czasKalendarz2 < 5 and czasKalendarz2 + mozliwyCzasNaPodlewanie * 60 >= 0 then
        return true
    end
    return false            
end

initKalendarza() -- nie nadąża wczytywać danych z tablic, wiec musi byc zainicjowane
-- gpio.write (pin, LED_OFF)
