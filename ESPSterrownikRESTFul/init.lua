-- node.flashreload("ESPCzujnikiRESTFul.img")
debugowanie = false
zapisDoInfluxDB = false

print ("Start bootowania...")
pcall(function()node.flashindex("bootowanie")()end)
