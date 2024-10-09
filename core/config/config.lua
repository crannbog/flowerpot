#!/usr/bin/env lua

-- Get flowerpot's directory
local flowerpot_dir_candidate = debug.getinfo(1, "S").source:sub(2)
local flowerpot_dir = flowerpot_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = flowerpot_dir .. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Imports
local logger = require("core.helper.logger")

local config = {}

function config.hello()
    logger.title("hello")
end

return config