#!/usr/bin/env lua

-- Get the current file's directory
local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")

-- Add the helpers/ directory to package.path so we can find logger.lua
package.path = current_dir .. "?.lua;" .. package.path
package.path = package.path .. ";../core/helper/?.lua"

-- imports
local update = require("update")
local logger = require("logger")

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