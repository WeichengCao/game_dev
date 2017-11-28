
function C2GSLogin(oConn, mData)
    local sAccount = mData.account
    local sPwd = mData.pwd
    oConn:Login(sAccount, sPwd)
end
