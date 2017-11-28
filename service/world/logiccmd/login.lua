local global = require "global"

function LoginPlayer(mRecord, mData)
    local iPid = mData.pid
    local mRole = mData.role
    global.oWorldMgr:LoginPlayer(iPid, mRole)
end
