--
local skynet = require "skynet.manager"
local interactive = require "base.interactive"
local net = require "base.net"
local global = require "global"
local share = require "base.share"
local texthandle = require "base.texthandle"
local logiccmd = import(service_path("logiccmd.init"))
local netcmd = import(service_path("netcmd.init"))
local world = import(service_path("world"))
local connection = import(service_path("connection"))

skynet.start(function()
    interactive.dispatch_logic(logiccmd)
    net.dispatch_net(netcmd)
    texthandle.init()

    global.oConnMgr = connection:NewConnectionMgr()
    global.oWorldMgr = world.NewWorldMgr()

    skynet.register(".world")

    interactive.send(".dictator", "common", "RegisterService", {
        addr = "."..MY_ADDR,
        inst = skynet.self(),
    })
    skynet.error("world service booted")
end)
