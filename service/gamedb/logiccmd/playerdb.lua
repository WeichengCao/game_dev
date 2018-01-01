local global = require "global"
local interactive = require "base.interactive"

local sTable = "player"

function InsertPlayerNameAndPid(mRecord, mData)
    local mInsert = {
        name = mData.name,
        pid = mData.pid,
    }
    local bSuccess = global.oGameDb:Insert(sTable, mInsert)
    interactive.respond(mRecord.source, mRecord.session, {success=bSuccess})
end
