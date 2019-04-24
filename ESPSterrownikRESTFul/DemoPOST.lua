pin=0
LED_OFF=1
LED_ON=0

pcall(function()node.flashindex("httpServer")()end)
print ("Wczytano modul httpServer")

httpServer:use('/zapiszU', function(req, res)
    print(req.source)
    res:type('application/json')
    res:send('{"status":"OK"}')   
end)

httpServer:listen(80)
