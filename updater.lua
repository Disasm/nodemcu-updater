web = require("web")

local handle = nil

web.on("/fwu/open/.*", function(request)
    if handle ~= nil then
        handle:close()
    end

    local filename = string.match(request.path, '/fwu/open/(.*)')

    if file.exists(filename) then
        file.remove(filename)
    end
    handle = file.open(filename, 'w+')
    if handle then
        request:answer(200, "OK")
    else
        handle = nil
        request:answer(200, "ERROR")
    end
end)

web.on("/fwu/write/.*", function(request)
    if handle == nil then
        request:answer(200, "ERROR")
        return
    end

    local data = string.match(request.path, '/fwu/write/(.*)')
    local bytes = string.len(data) / 2
    local binData = ""
    for i=1,bytes do
        local h = string.sub(data, i*2-1, i*2)
        binData = binData..string.char(tonumber(h, 16))
    end
    handle:write(binData)

    request:answer(200, "OK")
end)

web.on("/fwu/close", function(request)
    if handle == nil then
        request:answer(200, "ERROR")
        return
    else
        handle:close()
        handle = nil
        request:answer(200, "OK")
    end
end)
