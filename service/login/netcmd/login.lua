
function C2GSLogin(oConn, mData)
    local sAccount = mData.account
    oConn:Login(sAccount, sPwd)
end
