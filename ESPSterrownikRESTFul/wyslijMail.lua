gpio.write (pin, LED_ON)
local MY_EMAIL = "lutencjusz@gmail.com"  
local EMAIL_PASSWORD = crypto.decrypt("AES-ECB", key, encoder.fromHex(u.emailPass))  
-- u.emailPass ustawiana w module WiFi
 local SMTP_SERVER = "smtp.gmail.com"  
 local SMTP_PORT = "465"  
 local mail_to = "lutencjusz@gmail.com"  
 local email_subject = ""  -- ustawienie zmiennej początkowej
 local email_body = ""  -- ustawienie zmiennej początkowej
 local count = 0  -- licznik komunikatów
 local smtp_socket = nil -- will be used as socket to email server  
 
 function display(sck,response)  
    print("Otrzymano odpowiedz: ")  
    print(response)  
 end  
 
 function do_next_mail()  -- do prowadzenia dialogu z serwerem
       if(count == 0)then  
         count = count+1  
         local IP_ADDRESS = wifi.sta.getip()  
         print ("Send my IP: " .. IP_ADDRESS)  
         smtp_socket:send("HELO "..IP_ADDRESS.."\r\n")  
       elseif(count==1) then  
         count = count+1  
         smtp_socket:send("AUTH LOGIN\r\n")  
       elseif(count == 2) then  
         count = count + 1  
         smtp_socket:send(crypto.toBase64(MY_EMAIL).."\r\n")  
       elseif(count == 3) then  
         count = count + 1  
         smtp_socket:send(crypto.toBase64(EMAIL_PASSWORD).."\r\n")  
       elseif(count==4) then  
         count = count+1  
         smtp_socket:send("MAIL FROM:<" .. MY_EMAIL .. ">\r\n")  
       elseif(count==5) then  
         count = count+1  
         smtp_socket:send("RCPT TO:<" .. mail_to ..">\r\n")  
       elseif(count==6) then  
         count = count+1  
         smtp_socket:send("DATA\r\n")  
       elseif(count==7) then  
         count = count+1  
         local message = string.gsub(  
         "From: \"".. MY_EMAIL .."\"<"..MY_EMAIL..">\r\n" ..  
         "To: \"".. mail_to .. "\"<".. mail_to..">\r\n"..  
         "Subject: ".. email_subject .. "\r\n\r\n" ..  
         email_body,"\r\n.\r\n","")  
         smtp_socket:send(message.."\r\n.\r\n")  
       elseif(count==8) then  
         count = count+1  
          -- tmr.stop(4) 
          smtp_socket:send("QUIT\r\n")  
       else  
         smtp_socket:close()
         usunPlik("mejl.json") 
         node.restart()
       end  
 end
 
 function connected(sck)  
   print("Połączono się z serwerem. rozpoczynam wysyłanie...")  
   tmr.alarm(4,5000,1,do_next_mail)  
 end  

 function send_email()
    emails = wczytajPlikDoZmiennej('mejl.json')
    tMail = nil
    if emails ~= '' then
        local obE = sjson.decoder()
        if obE:write ("[" .. emails .. "]") == nil then
            print ("Blad przy odczycie pliku z poczta do wyslania! Usuwam mail.json")
            usunPlik("mejl.json")
        else
            tMail = obE:result()
        end
    end
    if emails ~= '' then
        for i = 1, #tMail do
            if debugowanie then
                print("Wysłano mejl!")
                print ("tMail[i].subject= " .. tMail[i].subject)
                print ("tMail[i].bodyt= " .. tMail[i].body)
            end
            -- zapiszAlarmyDoPliku(3, "Wystłano mejl!", ("Proba wyslania mejla " .. podajCzas()), "alert.json", "m1") 
            gpio.write (pin, LED_ON)  
            count = 0  
            email_subject = tMail[i].subject  
            email_body = tMail[i].body  
            print ("Otworzono połączenie...")  
            smtp_socket = net.createConnection(net.TCP,1)
            smtp_socket:on("connection",connected)  
            smtp_socket:on("receive",display)  
            smtp_socket:connect(SMTP_PORT,SMTP_SERVER)
            gpio.write (pin, LED_OFF)
        end
    else
        if debugowanie then
            print ('Nie ma mejli do wysłania!')
        end
    end
 end
