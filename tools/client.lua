package.path = package.path.."../service/?.lua"
require "tools.robot"
local socket = require "clientsocket"

function main(...)
    print(...)
    local oRobot = CRobot:New("127.0.0.1", 8102)

    local co = coroutine.create(function()
        oRobot:Start()
    end)

    while oRobot.m_bRuning do
--        local bRet, _ = coroutine.resume(co)
--        if not bRet then
--            print("robot start error")
--            oRobot.m_bRuning = false
--        end
        oRobot:Start()
        socket.usleep(1000000)
    end
end

main(...)
