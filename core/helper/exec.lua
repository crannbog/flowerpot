#!/usr/bin/env lua

local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")
package.path = current_dir .. "?.lua;" .. package.path

-- Import logger.lua
local logger = require("logger")

local exec = {}

-- Function to execute shell commands
local function run(command, hideCommand)
    hideCommand = hideCommand ~= nil and hideCommand or false
    -- local handle = io.popen("sh -c '" .. command .. "'")
    local handle = io.popen(command)
    local output = handle:read("*a")
    local success, _, exit_code = handle:close()

    if not success then
        logger.error("Command failed with exit code: " .. exit_code .. "\n" .. logger.add_whitespaces(command))
        return false, exit_code
    end

    output = logger.add_whitespaces(output)
    command = hideCommand and "" or command

    if hideCommand then
        logger.plain(output)
    else
        logger.verbose("\27[35m" .. "Executing command " .. logger.colors.reset .. logger.colors.verbose .. command .. logger.colors.reset .. "\n" .. output)
    end

    return true, exit_code
end

function exec.run(command, hideCommand)
    run(command, hideCommand)
end

return exec

