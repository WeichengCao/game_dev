local skynet = require "skynet"
local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))

function NewPerform(iPerform, mPerform)
    return CPerform:New(iPerform, mPerform)
end

CPerform = {}
CPerform.__index = CPerform
inherit(CPerform, baseobj.CBaseObj)

function CPerform:New(iPerform, mPerform)
    local o = super(CPerform).New(self)
    o.m_iPerform = iPerform
    o.m_mInfo = mPerform
    return o
end

function CPerform:GetLevel()
    return self:GetInfo("level", 0)
end

function CPerform:Perform(oAttack, iTarget)
    local oWar = oAttack:GetWarObj()
    assert(oWar)

    local lVictim = self:PerformTarget(oAttack, iTarget)
end

function CPerform:PerfromTarget(oAttack, iTarget)
end

function CPerform:PerformType()
    --物理，法术，封印
end

function CPerform:PerformRange()
    local mPerform = self:GetPerformInfo()
    return mPerform.range or 1
end

function CPerform:PerformTargetType()
    --己方 1，敌方 2
    local mPerform = self:GetPerformInfo()
    return mPerform.target_type or 2
end

function CPerform:GetPerformInfo()
    return share["daobiao"]["perform"][self.m_iPerform]
end

