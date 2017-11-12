local skynet = require "skynet"

local mCmd = {}
mCmd.login = import(service_path("netcmd.login"))

function Invoke(sMod, sMsg, fd, mData)
    safe_call(mCmd[sMod][sMsg], fd, mData)
end
