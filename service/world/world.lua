local skynet = require "skynet"
local baseobj = import(lualib_path("base.baseobj"))
local connection = import(service_path("connection"))

function NewWorldMgr(...)
    return CWorldMgr:New(...)
end

CWorldMgr = {}
CWorldMgr.__index = CWorldMgr
inherit(CWorldMgr, baseobj.CBaseObj)

function CWorldMgr:New(...)
    local o = super(CWorldMgr).New(self)
    o.m_mOnlinePlayers = {}
    o.m_mLoginPlayers = {}
    o.m_mConnections = {}
    return o
end

function CWorldMgr:GetOnlinePlayerByPid(iPid)
    return self.m_mOnlinePlayers[iPid]
end

function CWorldMgr:LoginPlayer(iPid, mRole)
    local oPlayer = self:GetOnlinePlayerByPid(iPid)
    if oPlayer then
        --TODO reenter
    else
        local oConn = self:CreateConnection(mRole)
        self:AddConnection(iPid, oConn)

        --TODO create playerobj
        --TODO load playerdata
        --TODO notify client login success
    end
end

function CWorldMgr:CreatePlayer(iPid)
end

function CWorldMgr:CreateConnection(mRole)
    return connection.NewConnection(mRole)
end

function CWorldMgr:AddConnection(iPid, oConn)
    local oOld = self.m_mConnections[iPid]
    if oOld then
        --TODO kick old connection
    end
    self.m_mConnections[iPid] = oConn
    oConn:Forward()
end
