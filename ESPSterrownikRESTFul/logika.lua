kom = sjson.decode(wczytajPlikDoZmiennej('komentarze.json'))
print ("    wczytano komentarze...")

function czyAlertPozZasVc (ob)
    if pTestowe.Vc > pCz.VcMax then
        ob.naglowek = kom.VcN1
        ob.opis = kom.Vc1.format(kom.Vc1, pTestowe.Vc, pTestowe.Vc_u, pCz.VcMax)..ob.opis
        ob.status = false
        ob.prior = 1
        ob.klucz = ob.klucz .. 'Vc1'
    elseif pTestowe.Vc < pCz.VcMin then
        ob.naglowek = kom.VcN2
        ob.opis = kom.Vc2.format(kom.Vc2, pTestowe.Vc, pTestowe.Vc_u, pCz.VcMin)..ob.opis
        ob.status = false
        ob.prior = 1
        ob.klucz = ob.klucz .. 'Vc2'
    end           
    return ob
end

function czyAlertPozZasVp (ob)
    if pTestowe.Vp > pCz.VpMax then
        ob.naglowek = kom.VpN1
        ob.opis = kom.Vp1.format(kom.Vp1, pTestowe.Vp, pCz.VpMax)..ob.opis
        ob.status = false
        ob.prior = 1
        ob.klucz = ob.klucz .. 'Vp1'
    elseif pTestowe.Vp < pCz.VpMin then
        ob.naglowek = kom.VpN2
        ob.opis = kom.Vp2.format(kom.Vp2, pTestowe.Vp, pCz.VpMin)..ob.opis
        ob.status = false
        ob.prior = 1
        ob.klucz = ob.klucz .. 'Vp2'
    end           
    return ob
end

function czyAlerthumidity (ob)
    czyUruchomicPompkiKalendarz1 = true
    if pTestowe.humidity > pCz.humidityMax then
        ob.naglowek = kom.hN1
        ob.opis = kom.h1.format(kom.h1, pTestowe.humidity, pCz.humidityMax)..ob.opis
        ob.status = false
        ob.prior = 2
        ob.klucz = ob.klucz .. "h1"
    elseif pTestowe.humidity < pCz.humidityMin then
        ob.naglowek = kom.hN2
        ob.opis = kom.h2.format(kom.h2, pTestowe.humidity, pCz.humidityMin)..ob.opis
        ob.klucz = ob.klucz .. "h2"
    elseif pTestowe.humidity > pCz.humidityOpt then
        ob.naglowek = kom.hN3
        ob.opis = kom.h3.format(kom.h3, pTestowe.humidity, pCz.humidityOpt)..ob.opis
        ob.klucz = ob.klucz .. "h3"
        if debugowanie then
            print ("Wyłączam poranne uruchomienie pompek!")
        end
        czyUruchomicPompkiKalendarz1 = false
    end         
    return ob
end

function czyAlertTempPow (ob)
    if pTestowe.temp > pCz.temp_max then
        ob.naglowek = kom.tN1
        ob.opis = kom.t1.format(kom.t1, pTestowe.temp, pTestowe.temp_u, pCz.temp_max)..ob.opis
        ob.status = false
        ob.prior = 2
        ob.klucz = ob.klucz .. "t1"
    elseif pTestowe.temp < pCz.temp_min then
        ob.naglowek = kom.tN2
        ob.opis = kom.t2.format(kom.t2, pTestowe.temp, pTestowe.temp_u, pCz.temp_min)..ob.opis
        ob.status = false
        ob.prior = 2
        ob.klucz = ob.klucz .. "t2"
    end           
    return ob
end

function czyAlertKalenadza (ob)
    if tLog == nil then
        print ("Blad przy odczycie tLog w czyAlertKalenadza! Nie sprawdzam tego alertu")
        return false
    end

    if tKalendarz == nil then
        print ("Blad przy odczycie tKalendarz w czyAlertKalenadza! Nie sprawdzam tego alertu")
        return false
    end
    local l = sjson.decode("[" .. tLog .. "]")
    local porDatyK1Tlog = odlegloscDaty(l[#l].dataPomiaru, konwersjaCzasNaData(tKalendarz[1]))
    local porDatyK2Tlog = odlegloscDaty(l[#l].dataPomiaru, konwersjaCzasNaData(tKalendarz[2]))
    if porDatyK1Tlog > 0 and porDatyK2Tlog > 0 then  wynikPorDatyKalTlog = 0
    -- porownanie ostatniego uruchomienia z kalendarzem
        elseif porDatyK1Tlog <= 0 and porDatyK2Tlog > 0 then  wynikPorDatyKalTlog = 1
        elseif porDatyK1Tlog <= 0 and porDatyK2Tlog <= 0 then  wynikPorDatyKalTlog = 2
    end -- jeśli wynik 0 - pompki nie byly uruchomione; 1 - byly po K1; 2 - były po K1 i K2
    if debugowanie then
        print ("        wynikPorDatyKalTlog: " .. wynikPorDatyKalTlog)
    end
    if wynikPorDatyKalTlog ~= 2 then -- sprawdza, czy już dzisiaj były uruchamiane
        local porDatyK1AktCzas = odlegloscDaty(konwersjaCzasNaData(tKalendarz[1]), podajCzas())
        local porDatyK2AktCzas = odlegloscDaty(konwersjaCzasNaData(tKalendarz[2]), podajCzas())
        if porDatyK1AktCzas < 0 and porDatyK2AktCzas < 0 then wynikPorDatyKalAktCzas = 0
        -- porównanie kalendarza z aktualnym czasem
            elseif porDatyK1AktCzas >= 0 and porDatyK2AktCzas < 0 then wynikPorDatyKalAktCzas = 1
            elseif porDatyK1AktCzas >= 0 and porDatyK2AktCzas >= 0 then wynikPorDatyKalAktCzas = 2
        end -- jeśli wynik 0 - jeszcze za wczesnie; 1 - pora na K1, 2 - pora na K1 i K2
        if debugowanie then
            print ("        wynikPorDatyKalAktCzas: " .. wynikPorDatyKalAktCzas)
        end
        if wynikPorDatyKalTlog >= wynikPorDatyKalAktCzas then 
        -- porownanie czy właściwa pora na uruchomienie z czasem uruchomnienia
            ob.opis = ob.opis .. kom.k2
            ob.klucz = ob.klucz .. "k2"
            ob.status = false
        else
            ob.opis = ob.opis .. kom.k3
            ob.klucz = ob.klucz .. "k3"
        end
    else
        ob.opis = ob.opis .. kom.k1
        ob.klucz = ob.klucz .. "k1"
        ob.status = false    
    end
    if debugowanie then
        print ("        w czyAlertKalenadza klucz: " .. ob.klucz)
    end
    return ob
end

function czyAlertPoziomuWody (ob)
    if not pTestowe.poziomWody then
        ileCzasu, ostatniPomiar = zaIleUruchomicPompkiKalendarz()
        if ileCzasu < ileCzasuDoWyslaniaMejla and ileCzasu > 0 and not czyWyslanoMejl then
            local body = kom.bodyM.format(kom.bodyM, podajCzasS(ileCzasu), ostatniPomiar)
            zapiszMejleDoPliku(kom.NM, body)
            czyWyslanoMejl = true
            ob.opis = ob.opis .. kom.pw1
            ob.klucz = ob.klucz .. "pw1"
        else
            ob.opis = kom.pw2 .. ob.opis
            ob.klucz = ob.klucz .. "pw2"
        end
        ob.status = false
        ob.naglowek = kom.pwN
        ob.prior = 1
    end       
    return ob
end

function czyAlertPrzedzialuCzasowego (ob)
    if debugowanie then
        print ("przed sprawdzeniem z czyAlertPrzedzialuCzasowego o= " .. ob.opis)
    end
    if czyMiesciSiePrzedzialeCzasowym () then
        ob.opis = ob.opis .. kom.pt1
        ob.klucz = ob.klucz .. "pt1"
        if ob.naglowek == '' then
            ob.naglowek = kom.ptN1
        end
    else 
        ob.opis = ob.opis .. kom.pt2
        if ob.naglowek == '' then
            ob.naglowek = kom.ptN2
        end
        ob.klucz = ob.klucz .. "pt2"
        ob.status = false
    end
    if debugowanie then
        print ("po sprawdzeniu z czyAlertKalenadza o= " .. ob.opis)
    end        
    return ob
end

function ustawienieAlertowLogiki (ob)
    ob = czyAlerthumidity(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlerthumidit:")
        print (ob.naglowek, ob.opis, ob.status, ob.prior, ob.klucz)
    end
    ob = czyAlertTempPow(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertTempPow:")
        print (ob.naglowek, ob.opis, ob.status, ob.prior, ob.klucz)
    end
    ob = czyAlertPozZasVp(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertPozZasVp:")
        print (ob.naglowek, ob.opis, ob.status, ob.prior, ob.klucz)
    end
    ob = czyAlertPozZasVc(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertPozZasVc:")
        print (ob.naglowek, ob.opis, ob.status, ob.prior, ob.klucz)
    end
    ob = czyAlertKalenadza(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertKalenadza")
        print (ob.naglowek, ob.opis, ob.status, ob.prior, ob.klucz)
    end
    ob = czyAlertPoziomuWody(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertPoziomuWody")
        print (ob.naglowek, ob.opis, ob.status, ob.prior, ob.klucz)
    end
    ob = czyAlertPrzedzialuCzasowego(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertPrzedzialuCzasowego")
        print (ob.naglowek, ob.opis, ob.status, ob.prior, ob.klucz)
    end
    return ob
end
