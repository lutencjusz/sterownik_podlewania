-- gpio.write (pin, LED_ON)
function wczytajPlikDoZmiennej(nazwaPliku)
    if file.open(nazwaPliku, "r") then 
        local lines = ""
        repeat
            local line = file:readline()
            if line then 
                lines = lines .. line
            end
        until line == nil 
        file:close()
        return lines
    else
        print ("Nie wczytano pliku: "..nazwaPliku)
        return "" 
    end
    file=nil; line=nil; lines=nil
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

function konwertujMejlNaObiekt (subject, body)
    ob={}
    ob.dataMejla = podajCzas() -- wymaga wcześniej wczytanego modułu WiFi
    ob.subject = subject
    ob.body = body
    return ob    
end

function zapiszAlarmyDoPliku(prior, naglowek, opis, nazwaPliku, klucz)
    if debugowanie then
        print ("Z zapiszAlarmyDoPliku zapisuje: ")
        print ("Priorytet: " .. prior)
        print ("Naglowek: " .. naglowek)
        print ("Opis: " .. opis)
        print ("Nazwa pliku: " .. nazwaPliku)
        print ("klucz: " .. klucz)
    end
    if file.exists(nazwaPliku) then
        local iloscWierszyLog = 0
        local wielkosc = 0
        iloscWierszyAlert, wielkosc = ileWierszyWPliku (nazwaPliku)
        if wielkosc > 3800 then
            przepiszPliki (nazwaPliku, "tmp.json", minIloscWierszyAlert, iloscWierszyAlert)
        end
        if file.open(nazwaPliku, "a+") then
            al = sjson.encode(konwerujAlertNaObiekt(prior, naglowek, opis, klucz))
            if al ~= '' and al ~= nil then
                local data = ','..sjson.encode(konwerujAlertNaObiekt(prior, naglowek, opis, klucz)) .. '\n'
                file.write(data)
            else 
                print ("zapiszAlarmyDoPliku: nie zapisany, alert jest pusty")
            end
            file.close()
        else
            print ("Nie zapisano do pliku: "..nazwaPliku)
            return "" 
        end
    elseif file.open(nazwaPliku, "w") then 
        local data = sjson.encode(konwerujAlertNaObiekt(prior, naglowek, opis, klucz)) .. '\n'
        file.write(data)
        file.close()
    end
    -- systemInfo("/dadajAlert max")
    file=nil; data=nil;
    collectgarbage()
    return aktualnaIloscWierszyLog
end

function zapiszMejleDoPliku(subject, body)
    if file.exists('mejl.json') then
        if file.open('mejl.json', "a+") then 
            local data = ', '..sjson.encode(konwertujMejlNaObiekt(subject, body))..'\n'
            file.write(data)
            file.close()
        else
            print ("Nie zapisano do pliku z mejlami ")
            return "" 
        end
    elseif file.open('mejl.json', "w") then 
        local data = sjson.encode(konwertujMejlNaObiekt(subject, body))..'\n'
        file.write(data)
        file.close()
    end
    systemInfo("zapisz Mejl")
    file=nil; data=nil;
    collectgarbage()
end

function znajdzOdpowiedz(s)
    local f1 = string.find(s, "close");
    return string.sub(s, f1+9)
end

function zapiszStrDoPliku(plik, s)
    if file.open(plik, "w") then 
        file.write(s)
        file.close()
    end
end

-- gpio.write (pin, LED_OFF)
