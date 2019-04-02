debugowanie = true
zapisDoInfluxDB = false

print ("Start bootowania...")
pcall(function()node.flashindex("bootowanie")()end)
