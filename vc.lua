function initADC()
    if adc.force_init_mode(adc.INIT_VDD33) then
	    print("Zbyt mała wartość zasilania...")
    else
        print ("Uruchomiono ADC...")
    -- node.restart()
    -- return -- don't bother continuing, the restart is scheduled
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
-- nz = adc.readvdd33(0)/1000 -- napięcie zasilania    
