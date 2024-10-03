#!/usr/bin/env lua

-- Get the current file's directory
local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")

-- Add the helpers/ directory to package.path so we can find logger.lua
package.path = current_dir .. "?.lua;" .. package.path

local fp = require("flowerpot_module")

-- Script stuff - handles the arguments

local func_name = arg[1]

if type(fp[func_name]) == "function" then
    fp[func_name](table.unpack(arg, 2))
else 
    logger.warn("No such function " .. func_name .. " in flowerpot.")
end
