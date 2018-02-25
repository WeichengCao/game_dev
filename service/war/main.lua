
local skynet = require "skynet.manager"
local global = require "global"
local interactive = require "base.interactive"
local share = require "base.share"
local logiccmd = import(service_path("logiccmd.init"))

skynet.start(function()
    interactive.dispatch_logic(logiccmd)

    interactive.send(".dictator", "common", "RegisterService", {
        addr = "."..MY_ADDR,
        inst = skynet.self(),
    })
    skynet.error("war service booted")
end)
