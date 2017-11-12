package.cpath = package.cpath..";./skynet/luaclib/?.so;".."./skynet/cservice/?.so"
package.path = package.path..";./lualib/?.lua;".."./skynet/lualib/?.lua"

--local skynet = require "skynet"
require "base.tableop"
local socket = require "clientsocket"
local protobuf = require "base.protobuf"
local netpack = require "netpack"
local netfind = require "base.netfind"

netfind.Init()



CRobot = {}
CRobot.__index = CRobot

function CRobot:New(sIp, iPort)
    local o = setmetatable({}, self)
    o.m_sIp = sIp
    o.m_iPort = iPort
    o.m_bRuning = true
    o.m_iFd = socket.connect(sIp, iPort)
    return o
end

function CRobot:Start()
    self:CheckSocketIO()
end

function CRobot:CheckSocketIO()
    pcall(function()
        self:CheckReceiveMsg()
        --self:CheckSendMsg()
        coroutine.yield()
    end)
end

function CRobot:CheckReceiveMsg()
    local msg = socket.recv(self.m_iFd)
    if msg then
        local sData, sz = string.unpack(">s2", msg)
        local iSize = sz - 3
        local iProto = 0
        for i = 1, 2 do
            iProto = iProto | string.byte(sData, i, i) << 8*(i-1)
        end
        local sMod, sMessage = table.unpack(netfind.FindGS2CProtoByIndex(iProto))
        tab = protobuf.decode(sMessage, string.sub(sData, 3, iSize))
        print("receive:", sMessage, table_serialize(tab))

        self:TestSend()
    end
end

function CRobot:TestSend()
    local sNet = self:PackData("C2GSLogin", {account="text"})
    socket.send(self.m_iFd, sNet)
end

function CRobot:PackData(sMessage, mData)
    local sData = protobuf.encode(sMessage, mData)
    local iProto = netfind.FindC2GSProtoByName(sMessage)
    assert(iProto, "can't find message"..sMessage)

    local lProto = {}
    for i = 1, 2 do
        table.insert(lProto, string.char(iProto % 256))
        iProto = iProto >> 8
    end
    table.insert(lProto, sData)

--    local sData = table.concat(lProto, "")
--    for i = 1, #sData do
--        print(i, string.byte(sData, i, i))
--    end
    return string.pack(">s2", sData)
    --return sData
end


