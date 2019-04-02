
function czyAlertPozZasVc (ob)
    if pTestowe.Vc > pCz.VcMax then
        ob.naglowek = "Zbyt wysokie napiecie zasilania układu!"
        ob.opis = "Vc("..pTestowe.Vc..")>Vc max("..pCz.VcMax..")! "..ob.opis
        ob.status = false
        ob.prior = 1
        ob.klucz = ob.klucz .. 'Vc1'
    elseif pTestowe.Vc < pCz.VcMin then
        ob.naglowek = "Zbyt niskie napiecie zasilania układu!"
        ob.opis = "Vc("..pTestowe.Vc..")<Vc min("..pCz.VcMin..")! "..ob.opis
        ob.status = false
        ob.prior = 1
        ob.klucz = ob.klucz .. 'Vc2'
    end           
    return ob
end

-- print (czyAlertPozZasVc ("1", "2", "3"))

function czyAlertPozZasVp (ob)
    if pTestowe.Vp > pCz.VpMax then
        ob.naglowek = "Zbyt wysokie napiecie zasilania pompek!"
        ob.opis = "Vp("..pTestowe.Vp..")>Vp max("..pCz.VpMax..")! "..ob.opis
        ob.status = false
        ob.prior = 1
        ob.klucz = ob.klucz .. 'Vp1'
    elseif pTestowe.Vp < pCz.VpMin then
        ob.naglowek = "Zbyt niskie napiecie zasilania pompek!"
        ob.opis = "Vp("..pTestowe.Vp..")<Vp min("..pCz.VpMin..")! "..ob.opis
        ob.status = false
        ob.prior = 1
        ob.klucz = ob.klucz .. 'Vp2'
    end           
    return ob
end

function czyAlerthumidity (ob)
-- pTestowe wymagaja modułu parametryZewn
    if pTestowe.humidity > pCz.humidityMax then
        ob.naglowek = "Zbyt wysoka wilgotnosc!"
        ob.opis = "Wilgotnosc ("..pTestowe.humidity..")>Wilgotnosc max("..pCz.humidityMax..")! "..ob.opis
        ob.status = false
        ob.prior = 2
        ob.klucz = ob.klucz .. "h1"
    elseif pTestowe.humidity < pCz.humidityMin then
        ob.naglowek = "Zbyt niska wilgotnosc. Czujnik uszkodzony!"
        ob.opis = "Wilgotonosc ("..pTestowe.humidity..")<Wilgotnosc min("..pCz.humidityMin..")! "..ob.opis
        ob.klucz = ob.klucz .. "h2"
    elseif pTestowe.humidity > pCz.humidityOpt then
        ob.naglowek = "Jeszcze zbyt wilgotno, aby uruchomić rano!"
        ob.opis = "Wilgotonosc ("..pTestowe.humidity..")>Wilgotnosc optymalna("..pCz.humidityOpt..")! "..ob.opis
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
        ob.naglowek = "Zbyt wysoka tempratura na podlewanie!"
        ob.opis = "Temperatura powietrza("..pTestowe.temp..','..pTestowe.temp_u..")>Tempertura powietrza max("..pCz.temp_max..")! "..ob.opis
        ob.status = false
        ob.prior = 2
        ob.klucz = ob.klucz .. "t1"
    elseif pTestowe.temp < pCz.temp_min then
        ob.naglowek = "Zbyt niska temperatura na podlewanie!"
        ob.opis = "Temperatura powietrza("..pTestowe.temp..','..pTestowe.temp_u..")<Temperatura powietrza min("..pCz.temp_min..")! "..ob.opis
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
        elseif porDatyK1Tlog < 0 and porDatyK2Tlog > 0 then  wynikPorDatyKalTlog = 1
        elseif porDatyK1Tlog < 0 and porDatyK2Tlog < 0 then  wynikPorDatyKalTlog = 2
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
            ob.opis = ob.opis .. " Pompki byly juz uruchomione, czekam na nastepne podlewanie!"
            ob.klucz = ob.klucz .. "k2"
            ob.status = false
        else
            ob.opis = ob.opis .. " Mozna podlewac!"
            ob.klucz = ob.klucz .. "k3"
        end
    else
        ob.opis = ob.opis .. " Pompki były już uruchamiane!"
        ob.klucz = ob.klucz .. "k1"
        ob.status = false    
    end
    if debugowanie then
        print ("        w czyAlertKalenadza klucz: " .. k)
    end
    return ob
end

function czyAlertPoziomuWody (ob)
    if not pTestowe.poziomWody then
        ileCzasu, ostatniPomiar = zaIleUruchomicPompkiKalendarz()
        if ileCzasu < ileCzasuDoWyslaniaMejla and ileCzasu > 0 and not czyWyslanoMejl then
            local body = "Proszę o uzupełnienie wody w konewce. Do uruchomienia pompek zostało " .. podajCzasS(ileCzasu) .. ' (' .. ostatniPomiar ..')!'
            send_email("Prośba ze sterownika podlewania", body)
            czyWyslanoMejl = true
            ob.opis = ob.opis .. "Wysłano mejl o uzupełnieniu wody w konewce! "
            ob.klucz = ob.klucz .. "pw1"
        else
            ob.opis = "Zbyt niski poziom wody w konefce! " .. ob.opis
            ob.klucz = ob.klucz .. "pw2"
        end
        ob.status = false
        ob.naglowek = "Brak wody w konefce!"
        ob.prior = 1
    end       
    return ob
end

function czyAlertPrzedzialuCzasowego (ob)
    if debugowanie then
        print ("przed sprawdzeniem z czyAlertPrzedzialuCzasowego o= " .. ob.opis)
    end
    if czyMiesciSiePrzedzialeCzasowym () then
        ob.opis = ob.opis .. " Uruchomienie pompek miesci sie obecnym czasie podlewania!"
        ob.klucz = ob.klucz .. "pt1"
    else 
        ob.opis = ob.opis .. " To nie jest pora na podlewanie!"
        if ob.naglowek == '' then
            ob.naglowek = ob.naglowek .. "To nie jest pora podlewania!"
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
        print (ob.naglowek, ob.opis, str(ob.status), str(ob.prior), ob.klucz)
    end
    ob = czyAlertTempPow(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertTempPow:")
        print (ob.naglowek, ob.opis, str(ob.status), str(ob.prior), ob.klucz)
    end
    ob = czyAlertPozZasVp(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertPozZasVp:")
        print (ob.naglowek, ob.opis, str(ob.status), str(ob.prior), ob.klucz)
    end
    ob = czyAlertPozZasVc(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertPozZasVc:")
        print (ob.naglowek, ob.opis, str(ob.status), str(ob.prior), ob.klucz)
    end
    ob = czyAlertKalenadza(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertKalenadza")
        print (ob.naglowek, ob.opis, str(ob.status), str(ob.prior), ob.klucz)
    end
    ob = czyAlertPoziomuWody(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertPoziomuWody")
        print (ob.naglowek, ob.opis, str(ob.status), str(ob.prior), ob.klucz)
    end
    ob = czyAlertPrzedzialuCzasowego(ob)
    if debugowanie then
        print ("Parametry logiki po czyAlertPrzedzialuCzasowego")
        print (ob.naglowek, ob.opis, str(ob.status), str(ob.prior), ob.klucz)
    end
    
    return ob
end

