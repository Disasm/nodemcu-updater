--uart.setup(0,115200,8,0,1)

gpio.mode(0, gpio.INPUT)

if gpio.read(0) == 1 then
    dofile("main.lua")
else
    print("Emergency mode, exiting")
end

