#!/usr/bin/env lua

local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")
package.path = current_dir .. "?.lua;" .. package.path

-- Import logger.lua
local logger = require("logger")

local files = {}

return files