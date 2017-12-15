local skynet = require "skynet"
local ltimer = require 'ltimer'

local oTimerMgr = nil

function get_time()
    return math.floor(skynet.time()*1000)
end

CTimerMgr = {}
CTimerMgr.__index = CTimerMgr

function CTimerMgr:New()
    local o = setmetatable({}, self)
    o.m_iDispatchId = 0
    ltimer.ltimer_create(get_time())
    return o
end

function CTimerMgr:DispatchId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CTimerMgr:AddTimeCb(func, iDelay)
    ltimer.ltimer_add_time(func, iDelay)
end

function CTimerMgr:CheckUpdate()
    ltimer.ltimer_update(get_time())
    skynet.timeout(1, function()
        self:CheckUpdate()
    end)
end


CTimer = {}
CTimer.__index = CTimer

function CTimer:New()
    local o = setmetatable({}, self)
    o.m_mKey2Index = {}
    o.m_mIndex2Func = {}
    return o
end

function CTimer:Release()
    self.m_mKey2Index = {}
    self.m_mIndex2Func = {}
end

function CTimer:AddTimeCb(sKey, iDelay, func)
    local iOldCb = self.m_mKey2Index[sKey]
    if iOldCb and self.m_mIndex2Func[iOldCb] then
        skynet.error("can't repeat add timer")
        self.m_mIndex2Func[iOldCb] = nil
        self.m_mKey2Index[sKey] = nil
    end

    local iCb = oTimerMgr:DispatchId()
    self.m_mKey2Index[sKey] = iCb
    self.m_mIndex2Func[iCb] = func
    
    local func = function()
        if self.m_mIndex2Func[iCb] then
            safe_call(self.m_mIndex2Func[iCb])
        end
        self.m_mKey2Index[sKey] = nil
        self.m_mIndex2Func[iCb] = nil
    end
    oTimerMgr:AddTimeCb(func, iDelay)
end

function CTimer:DelTimeCb(sKey)
    local iCb = self.m_mKey2Index[sKey]
    if iCb then
        self.m_mIndex2Func[iCb] = nil
    end
end

function CTimer:GetTimeCb(sKey)
    return self.m_mKey2Index[sKey]
end

local M = {}

M.Init = function()
    oTimerMgr = CTimerMgr:New()
    oTimerMgr:CheckUpdate()
end

M.NewTimer = function()
    return CTimer:New()
end

return M
