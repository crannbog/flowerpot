#!/usr/bin/env lua

-- Get own directory
local self_dir_candidate= debug.getinfo(1, "S").source:sub(2)
local self_dir= self_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = self_dir.. "?.lua;" .. package.path
package.path = package.path .. ";../?.lua"

-- Imports
local logger = require("core.helper.logger")
local update = require("manager.update")

local teleport = {}

function teleport.run(...)
    local args = {...}

    local user = exec.run("read -p 'Enter SSH username: '")

    logger.warn(user);
end

return teleport