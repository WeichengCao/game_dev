local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))
local warobj = import(service_path("war.warobj"))


function NewWarMgr()
    return CWarMgr:New()
end

CWarMgr = {}
CWarMgr.__index = CWarMgr
inherit(CWarMgr, baseobj.CBaseObj)

function CWarMgr:New()
    local o = super(CWarMgr).New(self)
    o.m_mWars = {}
    o.m_iDispatchId = 0
    return o
end

function CWarMgr:Release()
    for iWar, oWar in pairs(self.m_mWars) do
        oWar:Release()
    end
    super(CWarMgr).Release(self)
end

function CWarMgr:DispatchId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    if self.m_iDispatchId > 0x7fffffff then
        self.m_iDispatchId = 1
    end
    return self.m_iDispatchId
end

function CWarMgr:InitRemote(lRemote)
    self.m_lRemote = lRemote
    self.m_iRemoteHash = 0
    self.m_iRemoteSize = #lRemote
end

function CWarMgr:RandomRemote()
    self.m_iRemoteHash = self.m_iRemoteHash + 1

    if self.m_iRemoteHash > self.m_iRemoteSize then
        self.m_iRemoteHash = 1
    end
    return self.m_lRemote[self.m_iRemoteHash]
end

function CWarMgr:CreateWar(mConfig)
    local iWar = self:DispatchId()
    local iRemote = self:RandomRemote()
    local oWar = warobj.NewWar(iWar, iRemote, mConfig)
    oWar:ConfirmRemote()
    self.m_mWars[iWar] = oWar
    return oWar
end

function CWarMgr:RemoveWar(iWar)
    local oWar = self:GetWar(iWar)
    if oWar then
        oWar:Release()
        self.m_mWars[iWar] = nil
    end
end

function CWarMgr:GetWar(iWar)
    return self.m_mWars[iWar]
end

