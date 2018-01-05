local global = require "global"
local skynet = require "skynet"
local baseobj = import(lualib_path("base.baseobj"))
local ctrlinit = import(service_path("player.ctrl.init"))

function NewPlayerObj(...)
    return CPlayer:New(...)
end


CPlayer = {}
CPlayer.__index = CPlayer
inherit(CPlayer, baseobj.CDataCtrl)

function CPlayer:New(iPid, mRole)
    local o = super(CPlayer).New(self, iPid, mRole)
    o.m_iPid = iPid
    o.m_sName = ""
    o.m_bLoading = true
    o:InitRole(mRole)
    o:InitCtrlBlock(iPid, mRole)
    return o
end

function CPlayer:InitRole(mRole)
    self.m_sAccount = mRole.account
end

function CPlayer:InitCtrlBlock(iPid)
    self.m_oBaseCtrl = ctrlinit.NewBaseCtrl(iPid, mRole)--基础信息块
    self.m_oActiveCtrl = ctrlinit.NewActiveCtrl(iPid)   --活跃数据库
    self.m_oItemCtrl = ctrlinit.NewItemCtrl(iPid)       --道具信息块
    self.m_oTaskCtrl = ctrlinit.NewTaskCtrl(iPid)       --人物信息块
    self.m_oSummCtrl = ctrlinit.NewSummCtrl(iPid)       --宠物/召唤兽信息块
    self.m_oSkillCtrl = ctrlinit.NewSkillCtrl(iPid)     --技能信息块
    self.m_oWieldCtrl = ctrlinit.NewWieldCtrl(iPid)     --装备信息块
    self.m_oTodayCtrl = ctrlinit.NewTodayCtrl(iPid)     --天变量
    self.m_oWeekCtrl = ctrlinit.NewWeekCtrl(iPid)       --周变量
    self.m_oMonthCtrl = ctrlinit.NewMonthCtrl(iPid)     --月变量
    self.m_oTempCtrl = ctrlinit.NewTempCtrl(iPid)       --临时变量，自定义过期时间
end

function CPlayer:Release()
    self.m_oBaseCtrl:Release()
    self.m_oBaseCtrl = nil
    self.m_oActiveCtrl:Release()
    self.m_oActiveCtrl = nil
    self.m_oItemCtrl:Release()
    self.m_oItemCtrl = nil
    self.m_oTaskCtrl:Release()
    self.m_oTaskCtrl = nil
    self.m_oSummCtrl:Release()
    self.m_oSummCtrl = nil
    self.m_oSkillCtrl:Release()
    self.m_oSkillCtrl = nil
    self.m_oWieldCtrl:Release()
    self.m_oWieldCtrl = nil
    self.m_oTodayCtrl:Release()
    self.m_oTodayCtrl = nil
    self.m_oWeekCtrl:Release()
    self.m_oWeekCtrl = nil
    self.m_oMonthCtrl:Release()
    self.m_oMonthCtrl = nil
    self.m_oTempCtrl:Release()
    self.m_oTempCtrl = nil
end

function CPlayer:OnLogin(bReEnter)
    --safe_call(self.
end

function CPlayer:OnLogout()
end

function CPlayer:IsLoading()
    return self.m_bLoading
end

function CPlayer:LoadFinish()
    self.m_bLoading = false

    local iPid = self.m_iPid
    self:ApplySave(5, function()
        local oPlayer = global.oWorldMgr:GetOnlinePlayerByPid(iPid)
        if oPlayer then
            oPlayer:CheckSaveDb()
        end
    end)
end

function CPlayer:CheckSaveDb()
    self.m_oBaseCtrl:CheckSaveDb() 
    self.m_oActiveCtrl:CheckSaveDb()
    self.m_oItemCtrl:CheckSaveDb()
    self.m_oTaskCtrl:CheckSaveDb()
    self.m_oSummCtrl:CheckSaveDb()
    self.m_oSkillCtrl:CheckSaveDb()
    self.m_oSkillCtrl:CheckSaveDb()
    self.m_oTodayCtrl:CheckSaveDb()
    self.m_oWeekCtrl:CheckSaveDb()
    self.m_oMonthCtrl:CheckSaveDb()
    self.m_oTempCtrl:CheckSaveDb()
end

function CPlayer:GetGrade()
    return self.m_oActiveCtrl:GetGrade()
end

function CPlayer:GetSex()
    return self.m_oBaseCtrl:GetSex()
end

function CPlayer:GetSchool()
    return self.m_oBaseCtrl:GetSchool()
end

function CPlayer:SetName(sName)
    self.m_sName = sName
end

function CPlayer:GetName()
    return self.m_sName
end

function CPlayer:GetIcon()
    return self.m_oBaseCtrl:GetIcon()
end

function CPlayer:Send(sMessage, mData)
    local oConn = global.oConnMgr:GetConnectionByPid(self.m_iPid)
    if oConn then
        oConn:Send(sMessage, mData)
    end
end

