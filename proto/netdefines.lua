local M = {}

local C2GSProto2Index = {}
local C2GSIndex2Proto = {}
local GS2CProto2Index = {}
local GS2CIndex2Proto = {}


--------------------
local C2GSDefines = {}

C2GSDefines.login = {
    C2GSLogin = 1002,
}


local GS2CDefines = {}

GS2CDefines.login = {
    GS2CHello = 1001,
}
---------------------


for sModule, mDefines in pairs(C2GSDefines) do
    for sMessage, iProto in pairs(mDefines) do
        C2GSProto2Index[sMessage] = iProto
        C2GSIndex2Proto[iProto] = {sModule, sMessage}
    end
end

for sModule, mDefines in pairs(GS2CDefines) do
    for sMessage, iProto in pairs(mDefines) do
        GS2CProto2Index[sMessage] = iProto
        GS2CIndex2Proto[iProto] = {sModule, sMessage}
    end
end


M.C2GSProto2Index = C2GSProto2Index 
M.C2GSIndex2Proto = C2GSIndex2Proto 
M.GS2CProto2Index = GS2CProto2Index 
M.GS2CIndex2Proto = GS2CIndex2Proto 

return M
