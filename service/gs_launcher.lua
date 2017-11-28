local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("share")
    skynet.newservice("debug_console", 7001)
    skynet.newservice("dictator")
    skynet.newservice("gamedb")
    skynet.newservice("login")
    skynet.newservice("world")
end)
