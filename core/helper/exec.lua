#!/usr/bin/env lua

-- Get flowerpot's directory
local flowerpot_dir_candidate = debug.getinfo(1, "S").source:sub(2)
local flowerpot_dir = flowerpot_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = flowerpot_dir .. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Imports
local logger = require("core.helper.logger")

local exec = {}

-- Function to execute shell commands
local function run(command, hideCommand, requireSudo)
    hideCommand = hideCommand ~= nil and hideCommand or false
    requireSudo = requireSudo ~= nil and hideCommand or false

    local sudoPrefix = requireSudo and "sudo " or ""

    local handle = io.popen(sudoPrefix .. "sh -c '" .. command .. "'")
    local output = handle:read("*a")
    local success, _, exit_code = handle:close()

    if not success then
        logger.error("Command failed with exit code: " .. exit_code .. "\n" .. logger.add_whitespaces(command))
        logger.plain(_)
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

function exec.run(command, hideCommand, requireSudo)
    run(command, hideCommand, requireSudo)
end

function exec.sudo(command, hideCommand)
    run(command, hideCommand, true)
end

return exec

