local global = require "global"
local share = require "base.share"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))

function NewWar(iWar, iRemote, mConfig)
    return CWar:New(iWar, iRemote, mConfig)
end

CWar = {}
CWar.__index = CWar
inherit(CWar, baseobj.CBaseObj)

function CWar:New(iWar, iRemote, mConfig)
    local o = super(CWar).New(self)
    o.m_iWarId = iWar
    o.m_iRemote = iRemote
    o.m_fCallback = nil
    o:Init(mConfig)
    return o
end

function CWar:Release()
    --TODO
    super(CWar).Release(self)
end

function CWar:Init(mConfig)
    self.m_iType = mConfig.type
    self.m_iSubType = mConfig.subtype
    self.m_sName = mConfig.name
    --TODO
end

function CWar:ConfirmRemote()
    local mArgs = {
        war_id = self.m_iWarId,
        type = self.m_iType,
        subtype = self.m_iSubType,
        name = self.m_sName,
    }
    interactive.send(self.m_iRemote, "war", "ConfirmRemote", mArgs)
end

