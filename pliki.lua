-- gpio.write (pin, LED_ON)
function wczytajPlikDoZmiennej(nazwaPliku)
    if file.open(nazwaPliku, "r") then 
        local line=file.read()
        file.close()
        return line
    else
        print ("Nie wczytano pliku: "..nazwaPliku)
        return "" 
    end
    file=nil; line=nil
    collectgarbage()
end

function usunPlik(nazwaPliku)
    if file.open(nazwaPliku, "r") then 
        file.remove(nazwaPliku)
    else
        print ("Nie wczytano pliku: "..nazwaPliku)
        return "" 
    end
    file.close()
    file=nil;
    collectgarbage()
end

function ileWierszyWPliku (nazwaPliku)
   local licznik=0
   local wielkosc=0
   if file.open(nazwaPliku, "r") then
        repeat
            line = file.readline()
            if line then
                licznik = licznik + 1
                wielkosc = wielkosc + #line
            end
        until line == nil
        file.close()
    end 
    file=nil; line=nil; plik=nil
    collectgarbage()
    return licznik, wielkosc
end

function przepiszPliki (pz, ptmp, iloscLiniPlikuD, iloscLiniiPlikuZ)
    -- pz - plik zródłowy
    -- ptmp - plik tymczasowy
    -- maxLiniCz - maksymalna liczba linii
    ali = iloscLiniiPlikuZ --ilosc linii pliku zrodlowego
    li = iloscLiniPlikuD --max ilosc linii pliku docelowego
    src = file.open(pz, "r") --przepisywanie plikow
    if src then
        dest = file.open(ptmp, "a+")
        if dest then
            local line
            repeat
                line = src:readline()
                ali = ali - 1
                if line and li >= ali then
                    if string.find (line, "taki sam") ~= nil and line ~= nil then
                        dest:write(line)
                        li = li - 1
                    end
                end
            until line == nil or li == 0
            dest:close(); dest = nil
        end
        src:close(); dest = nil
    end
    file.remove(pz)
    file.rename(ptmp, pz)
    src=nil; dest=nil; li=nil
    collectgarbage() -- czyszczenie pamięci  
end

function wyslijPlik(nazwaPliku, conn)
    local plik = "[\n"
    if file.open(nazwaPliku, "r") then
        repeat
            line = file.readline()
            if line then
                --print("linia: "..line)
                plik = plik..line
            end
        until line == nil
        plik = plik.."]\n"
    else
        print ("Nie wczytano pliku: "..nazwaPliku)
        plik = plik.."]\n"
    end
    file.close()
    conn:send(plik)
    systemInfo("/wszystko max")
    file=nil; line=nil; plik=nil
    collectgarbage()
end

function odswierzZakresyCzujnikow()
    print(" Wczytuje parametry czujnikow...")
    plik = file.open ("parametryCz.json","r")
    if plik == nil then
        print ("Nie znalazłem pliku: parametryCz.json")
    else
        pCzPlik=plik:read()
        file.close()
        pCz = sjson.decode(pCzPlik)
    end
end

function konwerujAlertNaObiekt (prior, naglowek, opis, klucz)
    ob={}
    ob.dataAlertu = podajCzas() -- wymaga wcześniej wczytanego modułu WiFi
    ob.prior = prior;
    ob.naglowek = naglowek
    ob.opis = opis
    ob.klucz = klucz
    return ob
end

function zapiszAlarmyDoPliku(prior, naglowek, opis, nazwaPliku, klucz)
-- dodatkowo potrzebuje:
--  maxIloscWierszyAlert
--  minIloscWierszyAlert
-- prior - priorytet
    if file.exists(nazwaPliku) then
        local iloscWierszyLog = 0;
        iloscWierszyAlert, wielkosc = ileWierszyWPliku (nazwaPliku)
        if wielkosc > 4000 then
            przepiszPliki (nazwaPliku, "tmp.json", minIloscWierszyAlert, iloscWierszyAlert)
        end
        if file.open(nazwaPliku, "a+") then 
            local data = ","..sjson.encode(konwerujAlertNaObiekt(prior, naglowek, opis, klucz)).."\n"
            file.write(data)
            file.close()
        else
            print ("Nie wczytano pliku: "..nazwaPliku)
            return "" 
        end
    elseif file.open(nazwaPliku, "w") then 
        local data = sjson.encode(konwerujAlertNaObiekt(prior, naglowek, opis, klucz)).."\n"
        file.write(data)
        file.close()
    end
    systemInfo("/dadajAlert max")
    file=nil; data=nil;
    collectgarbage()
    return aktualnaIloscWierszyLog
end
-- gpio.write (pin, LED_OFF)
