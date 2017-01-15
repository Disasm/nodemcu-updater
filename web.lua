if web then
    if web.srv then
        web.srv:close()
    end
end

web = {}
web.listen = function(port)
    web.subscribers = {}
    web.subscriberList = {}

    if web.srv then
        web.srv:close()
    end
    web.srv = net.createServer(net.TCP)
    web.srv:listen(port, function(conn)
        conn:on("receive",function(conn, payload)
            local request = {}
            request.payload = payload
            request.method = string.match(payload, '^([A-Z]+) ')
            request.path = string.match(payload, '[A-Z]+ (/[^ ]*) ')
            request.conn = conn
            request.answered = false
            request.answer = web.answer
            request.sendFile = web.sendFile

            local i
            for i=1,#web.subscriberList do
                m = string.match(request.path, '^'..web.subscriberList[i]..'$')
                if m then
                    local func = web.subscribers[web.subscriberList[i] ] 
                    if func ~= nil then
                        func(request)
                        break
                    end
                end
            end

            if request.answered == false then
                print("501 at "..request.path)
                web.answer(request, 501)
            end
        end)
    end)
end

web.on = function(path, func)
    web.subscribers[path] = func
    web.subscriberList[#web.subscriberList + 1] = path
end

web.codeName = function(code)
    if code == 200 then
        return "OK"
    elseif code == 404 then
        return "Not Found"
    elseif code == 500 then
        return "Internal Server Error"
    elseif code == 501 then
        return "Not Implemented"
    else
        return "UnknownCode"
    end
end

web.answer = function(request, code, data, headers)
    local conn = request.conn

    data0 = "HTTP/1.1 "..code.." "..web.codeName(code).."\r\n"
    if headers ~= nil then
        data0 = data0..headers
    else
        data0 = data0.."Content-type: text/html;charset=utf8\r\n"
    end
    data0 = data0.."\r\n"

    if data ~= nil then
        data0 = data0..data
    else
        data0 = data0..code.." "..web.codeName(code)
    end

    conn:send(data0, conn.close)

    request.answered = true
end

web.sendFile = function(request, fileName)
    request.answered = true
    local conn = request.conn
    if file.open(fileName, "r") then
        sendNext = function(conn)
            data = file.read(128)
            if data == nil then
                file.close()
                conn:close()
            else
                conn:send(data, send)
            end
        end
        conn:on("sent", sendNext)

        conn:send("HTTP/1.1 200 OK\r\n\r\n")
    else
        web.answer(request, 404, "Not Found")
    end
end

return web
