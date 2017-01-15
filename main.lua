local wifiParams = {}
if file.open("wifi.cfg", "r") then
    local s = file.read()
    wifiParams = cjson.decode(s)
    file.close()
end
if wifiParams.ssid == nil then
    wifiParams.ssid = "AccessPointName"
    wifiParams.password = "password1234"

    file.open("wifi.cfg", "w+")
    file.write(cjson.encode(wifiParams))
    file.close()
end
wifi.setmode(wifi.STATION)
wifi.sta.config(wifiParams.ssid, wifiParams.password)
wifi.sta.autoconnect(1)
--wifi.sta.connect()
--print("IP Address: "..tostring(wifi.sta.getip()))


print("Starting web server...")
-- a simple http server
web=require("web")
web.listen(80)
web.on("/", function(request)
    request:sendFile("index.html")
end)

require("updater")

web.on(".*", function(request)
    print("Default handler, request.path='"..request.path.."'")
    request:answer(200, "HELLO")
end)


print("Done")
