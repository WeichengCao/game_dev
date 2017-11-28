local M = {}

--M.test = import(service_path("netcmd.test"))

function M.Invoke(sMod, sMsg, fd, mData)
    if not M[sMod] then
        skynet.error("uninit net module:"..sMod)
        return
    end
    M[sMod][sMsg](fd, mData)
end
