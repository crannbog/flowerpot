#!/usr/bin/env lua

-- Get flowerpot's directory
local flowerpot_dir_candidate = debug.getinfo(1, "S").source:sub(1)
local flowerpot_dir = flowerpot_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = flowerpot_dir .. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Imports
local logger = require("core.helper.logger")
local update = require("manager.update")

local manager = {}

function manager.update()
    update()
end

function manager.run(method, ...)
    local args = {...}

    if type(manager[method]) == "function" then
        manager[method](table.unpack(args, 2))
    else
        logger.warn("Method " .. method .. " not found. Skipping.")
    end
end

return manager