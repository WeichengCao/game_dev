local skynet = require "skynet"
local global = require "global"

local basectrl = import(service_path("player.ctrl.base"))
local activectrl = import(service_path("player.ctrl.active"))
local itemctrl = import(service_path("player.ctrl.item"))

function NewBaseCtrl(iPid, mRole)
    return basectrl.CBaseCtrl:New(iPid, mRole)
end

function NewActiveCtrl(iPid)
    return activectrl.CActiveCtrl:New(iPid)
end

function NewItemCtrl(iPid)
    return itemctrl.CItemCtrl:New(iPid)
end

function NewTaskCtrl(iPid)
end

function NewSummCtrl(iPid)
end

function NewSkillCtrl(iPid)
end

function NewWieldCtrl(iPid)
end

function NewTodayCtrl(iPid)
end

function NewWeekCtrl(iPid)
end

function NewMonthCtrl(iPid)
end

function NewTempCtrl(iPid)
end

