#!/usr/bin/env lua

-- Get the current file's directory
local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")

-- Add the helpers/ directory to package.path so we can find logger.lua
package.path = current_dir .. "?.lua;" .. package.path
package.path = package.path .. ";../?.lua"

-- imports
local logger = require("core.helper.logger")
local exec = require("exec")

-- stuff

local function update(...)
    local args = {...}

    exec.run("git pull")
end

return update