local skynet = require "skynet"

function get_time(bFloat)
    if bFloat then
        return skynet.time()
    else
        return math.floor(skynet.time())
    end
end
