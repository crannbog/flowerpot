#!/usr/bin/env lua

-- Get flowerpot's directory
local flowerpot_dir_candidate = debug.getinfo(1, "S").source:sub(2)
local flowerpot_dir = flowerpot_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = flowerpot_dir .. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Get the current file's directory
local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")

-- Add the helpers/ directory to package.path so we can find logger.lua
package.path = current_dir .. "?.lua;" .. package.path

-- imports

local logger = require("core.helper.logger")
local exec = require("core.helper.exec")
local info = require("core.helper.logSysInfo")
local managerModule = require("manager.manager")
local configModule = require("core.config.config")

local fp = {}

local function test() 
end

local function manager() 
end

function fp.test()
    logger.info("Flowerpot is working. Noot Noot.")
    configModule.hello()
end

function fp.update()
    logger.info("Updating flowerpot in " .. current_dir)
    exec.run("cd " .. current_dir .. " && git pull")
    exec.sudo("cd " .. current_dir .. " && bash " .. current_dir .. "install.sh")
end

function fp.info()
    info()
end

function fp.manager(...)
    local args = {...}
    managerModule.run(args[1])
end

-- export the fp module

return fp