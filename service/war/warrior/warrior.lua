local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))
local defines = import(lualib_path("base.defines"))

CWarrior = {}
CWarrior.__index = CWarrior
inherit(CWarrior, baseobj.CBaseObj)

function CWarrior:New(iWid, iWar)
    local o = super(CWarrior).New(self)
    o.m_iWid = iWid                 --战斗单位id
    o.m_iWarId = iWar               --战斗对象id
    o.m_iPos = nil                  --战斗中站位
    o.m_iType = nil                 --战斗单位类型
    o.m_iCamp = nil                 --阵营
    o.m_oPerformMgr = nil           --招式管理器
    return o
end

function CWarrior:Release()
    super(CWarrior).Release(self)
end

function CWarrior:Init(mInit)
    self.m_mInfo = mInit
end

function CWarrior:GetWid()
    return self.m_iWid
end

function CWarrior:SetPos(iPos)
    self.m_iPos = iPos
end

function CWarrior:GetPos()
    return self.m_iPos
end

function CWarrior:SetCamp(iCamp)
    self.m_iCamp = iCamp
end

function CWarrior:GetCamp(iCamp)
    return self.m_iCamp
end

function CWarrior:IsPlayer()
    return self.m_iType == defines.WARRIOR_TYPE.PLAYER
end

function CWarrior:IsSummon()
    return self.m_iType == defines.WARRIOR_TYPE.SUMMON
end

function CWarrior:IsNpc()
    return self.m_iType == defines.WARRIOR_TYPE.NPC
end

function CWarrior:IsAlive()
    return self:GetInfo("hp", 0) > 0
end

function CWarrior:AddHp(iAdd)
end

function CWarrior:AddMp(iAdd)
end

function CWarrior:RefreshClientProp(mProp)
end

function CWarrior:Send(sMessage, mData)
end

function CWarrior:GetWarObj()
    return global.oWarMgr:GetWar(self.m_iWarId)
end

function CWarrior:IsAutoOperator()
    return false
end

function CWarrior:AICommand()
end

function CWarrior:CheckChangeCmd(mCmd)
end

function CWarrior:GetSpeed(sCmd, mData)
    return 100
end


