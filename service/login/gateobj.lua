local skynet = require "skynet.manager"
local global = require "global"
local net = require "base.net"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))


function NewGateMgr(...)
    return CGateMgr:New(...)
end

function NewGateObj(...)
    return CGateObj:New(...)
end

function NewConnection(...)
    return CConnection:New(...)
end

CGateMgr = {}
CGateMgr.__index = CGateMgr
inherit(CGateMgr, baseobj.CBaseObj)

function CGateMgr:New(...)
    local o = super(CGateMgr).New(self)
    o:Init()
    return o
end

function CGateMgr:Init()
    self.m_mGateObj = {}
    self.m_mConnObj = {}
end

function CGateMgr:InitAllGateObj()
    local iPort = skynet.getenv("gate_port")
    local oGate = NewGateObj(iPort)
    self:AddGateObj(oGate)
end

function CGateMgr:AddGateObj(oGate)
    self.m_mGateObj[oGate.m_iAddr] = oGate
end

function CGateMgr:AddConnection(oConn)
    local iFd = oConn:GetFd()
    self.m_mConnObj[iFd] = oConn
    self:OnAddConnection(oConn)
end

function CGateMgr:OnAddConnection(oConn)
    oConn:Forward()
end

function CGateMgr:GetConnection(iFd)
    return self.m_mConnObj[iFd]
end

function CGateMgr:RemoveConnection(iFd)
    local oConn = self.m_mConnObj[iFd]
    if not oConn then return end

    self.m_mConnObj[iFd] = nil
    self:OnRemoveConnection(oConn)
end

function CGateMgr:OnRemoveConnection(oConn)
    --TODO kick
end




CGateObj = {}
CGateObj.__index = CGateObj
inherit(CGateObj, baseobj.CBaseObj)

function CGateObj:New(iPort)
    local o = super(CGateObj).New(self)
    o.m_mConnection = {}
    o:Init(iPort)
    return o
end

function CGateObj:Init(iPort)
    self.m_iAddr = skynet.launch("gate", "S", "."..MY_ADDR, iPort, skynet.PTYPE_SOCKET, 5000)
    self.m_iPort = iPort
end


----------------------
CConnection = {}
CConnection.__index = CConnection
inherit(CConnection, baseobj.CBaseObj)

function CConnection:New(iGateAddr, iFd, iPort)
    local o = super(CConnection).New(self)
    o.m_iGateAddr = iGateAddr
    o.m_iFd = iFd
    o.m_iPort = iPort
    return o
end

function CConnection:GetGateAddr()
    return self.m_iGateAddr
end

function CConnection:GetFd()
    return self.m_iFd
end

function CConnection:MailAddr()
    return {addr = self.m_iGateAddr, fd = self.m_iFd}
end

function CConnection:Forward()
	skynet.send(self.m_iGateAddr, "text", "forward", self.m_iFd, skynet.address(skynet:self()), skynet.address(self.m_iGateAddr));
    skynet.send(self.m_iGateAddr, "text", "start", self.m_iFd)

    net.Send(self:MailAddr(), "GS2CHello", {})
end

function CConnection:Login(sAccount, sPwd, iPid)
    --TODO veritify
    local mRole = {
        account = sAccount, 
        pwd = sPwd,
        addr = self.m_iGateAddr,
        fd = self.m_iFd,
        port = self.m_iPort,
    }
    interactive.send(".world", "login", "LoginPlayer", {pid = iPid, role = mRole})
end

