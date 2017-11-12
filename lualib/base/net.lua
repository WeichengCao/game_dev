local skynet = require "skynet"
local netpack = require "netpack"
local protobuf = require "base.protobuf"
local netfind = require "base.netfind"

local M = {}
local netcmd = {}

function M.Init()
end

function M.dispatch_net(m)

    netcmd = m

    skynet.register_protocol(
        {
            name = "client",
            id = skynet.PTYPE_CLIENT,
            pack = function(...) return ... end,
        }
    )

    skynet.register_protocol(
        {
            name = "gate",
            id = skynet.PTYPE_SOCKET,
            unpack = function(...) return ... end,
        }
    )

    skynet.dispatch("gate", function(session, source, msg, sz)
        local sData = netpack.tostring2(msg, sz)
        local sProto = string.sub(sData, 1, 2)
        local iProto = 0
        for i = 1, 2 do
            iProto = iProto | string.byte(string.sub(sProto, i, i)) << 8*(i-1)
        end
        local sMod, sMsg = table.unpack(netfind.FindC2GSProtoByIndex(iProto))
        assert(sMod and sMsg, "error proto mod:"..sMod..",msg:"..sMsg..",proto:"..iProto)

        local sData = string.sub(sData, 3, sz)
        local mData = protobuf.decode(sMsg, sData)

        safe_call(netcmd.Invoke, sMod, sMsg, fd, mData)
    end)
end

function M.PackData(sMessage, mData)
    local sData = protobuf.encode(sMessage, mData)
    local iProto = netfind.FindGS2CProtoByName(sMessage)
    assert(iProto, "can't find message"..sMessage)

    local lProto = {}
    for i = 1, 2 do
        table.insert(lProto, string.char(iProto % 256))
        iProto = iProto >> 8
    end
    table.insert(lProto, sData)
    
    local sData = table.concat(lProto, "")
    return string.pack(">s2", sData)
end

function M.Mask(sMessage, mData)
end

function M.UnMask(sMessage, mData)
end

function M.Send(mMail, sMessage, mData)
    local iAddr = mMail.addr
    local iFd = mMail.fd
    local sData = M.PackData(sMessage, mData)
    local lData = {sData}
    for i = 1, 4 do
        table.insert(lData, string.char(iFd % 256))
        iFd = iFd >> 8
    end
    skynet.send(iAddr, "client", table.concat(lData, ""))
end

return M
