local skynet = require "skynet"
local baseobj = import(lualib_path("base.baseobj"))

function NewConnection(...)
    return CConnection:New(...)
end

CConnection = {}
CConnection.__index = CConnection
inherit(CConnection, baseobj.CBaseObj)

function CConnection:New(mRole)
    local o = super(CConnection).New(self)
    o.m_iGateAddr = mRole.addr
    o.m_iFd = mRole.fd
    o.m_iPort = mRole.port
    return o
end

function CConnection:MailAddr()
    return {addr = self.m_iGateAddr, fd = self.m_iFd}
end

function CConnection:Forward()
	skynet.send(self.m_iGateAddr, "text", "forward", self.m_iFd, skynet.address(skynet:self()), skynet.address(self.m_iGateAddr));
end

