-- https://myaccount.google.com/security
-- dostęp do mniej bezpiecznych aplikaji należy włączyć
-- wymaga WiFi.lua
gpio.write (pin, LED_ON)
local MY_EMAIL = "lutencjusz@gmail.com"  
local EMAIL_PASSWORD = crypto.decrypt("AES-ECB", key, encoder.fromHex(u.emailPass))  
-- u.emailPass ustawiana w module WiFi
 local SMTP_SERVER = "smtp.gmail.com"  
 local SMTP_PORT = "465"  
 local mail_to = "lutencjusz@gmail.com"  
-- local SSID = "Tech_D0044603"  
-- local SSID_PASSWORD = "RBRVEZZV"  
 -- configure ESP as a station  
-- station_cfg={}
-- station_cfg.ssid=SSID
-- station_cfg.pwd=SSID_PASSWORD
-- station_cfg.save=true
-- wifi.sta.config(station_cfg)
 -- These are global variables. Don't change their values  
 -- they will be changed in the functions below  
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
          tmr.stop(4)  
          smtp_socket:send("QUIT\r\n")  
       else  
         smtp_socket:close()
       end  
 end  
 -- The connectted() function is executed when the SMTP socket is connected to the SMTP server.  
 -- This function will create a timer to call the do_next function which will send the SMTP commands  
 -- in sequence, one by one, every 5000 seconds.   
 -- You can change the time to be smaller if that works for you, I used 5000ms just because.  
 function connected(sck)  
   print("Połączono się z serwerem. rozpoczynam wysyłanie...")  
   tmr.alarm(4,5000,1,do_next_mail)  
 end  

 function send_email(subject,body)
    gpio.write (pin, LED_ON)  
    count = 0  
    email_subject = subject  
    email_body = body  
    print ("Otworzono połączenie...")  
    smtp_socket = net.createConnection(net.TCP,1)  --,1
    smtp_socket:on("connection",connected)  
    smtp_socket:on("receive",display)  
    smtp_socket:connect(SMTP_PORT,SMTP_SERVER)
    gpio.write (pin, LED_OFF)
 end  
 -- Send an email  
 -- print ("Sending started...")  
 -- send_email("ESP8266-GMailSender","Hi there!")  
gpio.write (pin, LED_OFF)
