#!/usr/bin/env lua

-- Get own directory
local self_dir_candidate= debug.getinfo(1, "S").source:sub(2)
local self_dir= self_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = self_dir.. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Get the current file's directory
local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")

-- Add the helpers/ directory to package.path so we can find logger.lua
package.path = current_dir .. "?.lua;" .. package.path

FF_DIR = current_dir; 

-- imports

local logger = require("core.helper.logger")
local exec = require("core.helper.exec")
local info = require("core.helper.logSysInfo")
local managerModule = require("manager.manager")
local configModule = require("core.config.config")
local installDocker = require("core.installer.install-docker")


local fp = {}

function fp.test()
    logger.info("Flowerpot is working. Noot Noot.")
    configModule.hello()
end

function fp.update()
    logger.info("Updating flowerpot in " .. current_dir)
    exec.run("cd " .. current_dir .. " && git pull")
end

function fp.info()
    info()
end

function fp.relog()
    exec.run("sudo -k su -l $USER &")
end

function fp.docker()
    installDocker.install()
end

function fp.manager(...)
    local args = {...}
    managerModule.run(args[1])
end

-- export the fp module

return fp