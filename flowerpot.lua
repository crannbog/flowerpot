#!/usr/bin/env lua

-- Get flowerpot's directory
local flowerpot_dir_candidate = debug.getinfo(1, "S").source:sub(2)
local flowerpot_dir = flowerpot_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = flowerpot_dir .. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Imports
local logger = require("core.helper.logger")
local fp = require("flowerpot_module")

-- Script stuff - handles the arguments

local func_name = arg[1]

if type(fp[func_name]) == "function" then
    fp[func_name](table.unpack(arg, 2))
else 
    logger.warn("No such function " .. func_name .. " in flowerpot.")
end
