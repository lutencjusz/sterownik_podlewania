pcall(function()node.flashindex("httpServer")()end)
print ("Wczytano modul httpServer")

pcall(function()node.flashindex("kalendarz")()end)
print ("Wczytano modul kalendarz")

pcall(function()node.flashindex("logika")()end)
print ("Wczytano modul Logika")

if zapisDoInfluxDB then
    pcall(function()node.flashindex("InfluxDB")()end)
    print ("Wczytano modul InfluxDB")
else
    print ("Nie wczytano modulu InfluxDB")
end

pcall(function()node.flashindex("ServerWWW")()end)
print ("Wczytano modul ServerWWW")

