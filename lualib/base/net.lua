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
        local fd = 0
        for i = 1, 4 do
            fd = fd | string.byte(string.sub(sData, i, i)) << 8*(i-1)
        end
        local sProto = string.sub(sData, 5, 6)
        local iProto = 0
        for i = 1, 2 do
            iProto = iProto | string.byte(string.sub(sProto, i, i)) << 8*(i-1)
        end
        local sMod, sMsg = table.unpack(netfind.FindC2GSProtoByIndex(iProto))
        assert(sMod and sMsg, "error proto mod:"..sMod..",msg:"..sMsg..",proto:"..iProto)

        local sData = string.sub(sData, 7, sz)
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
    --mask 为64位, 但因为lua对于大数的表示是科学记数法，无法完全使用64位
    --不同版本的lua对大数解析有不同的结果,因此不能完全用满64位,
    --这里只是提供一种思路，也可以把mask使用string来表示
    local mNameField = protobuf.name_field(sMessage)
    assert(mNameField.mask == 1)

    local iMask = 0
    for sKey, rVal in pairs(mData) do
        local iNo = mNameField[sKey]
        iMask = iMask | (1 << (iNo-1))
    end
    mData.mask = iMask
    return mData
end

function M.UnMask(sMessage, mData)
    --Mask 的逆过程
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
