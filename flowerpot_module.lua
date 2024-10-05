#!/usr/bin/env lua

-- Get the current file's directory
local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")

-- Add the helpers/ directory to package.path so we can find logger.lua
package.path = current_dir .. "?.lua;" .. package.path

-- imports

local logger = require("core.helper.logger")
local exec = require("core.helper.exec")
local managerModule = require("manager.manager")

local fp = {}

local function test() 
end

local function manager() 
end

function fp.test()
    logger.info("Flowerpot is working. Noot Noot.")
end

function fp.update()
    logger.info("Updating flowerpot in " .. current_dir)
    exec.run("cd " .. current_dir .. " && git pull && bash install.sh")
end

function fp.manager(...)
    local args = {...}
    managerModule.run(args[1])
end

-- export the fp module

return fp