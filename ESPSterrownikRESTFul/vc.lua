function initADC()
    if adc.force_init_mode(adc.INIT_VDD33) then
	    print("Zbyt mała wartość zasilania...")
    else
        print ("Uruchomiono ADC...")
    end
end

function parsowanieVc ()
    local c = adc.readvdd33(0)/1000
    local u = adc.readvdd33(0)/10
    if c == nil or u == nil then
        print ("Nie udalo sie odczytac danych z ADC...")
        return 0, 0
    else
        u = u - c*100
        if debugowanie then
            print ("Vc= " .. c .. "." .. u)
        end
        return tonumber(c), tonumber(u)
    end
end

initADC()
