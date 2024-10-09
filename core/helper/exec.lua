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

local function escape_single_quotes(cmd)
    return cmd:gsub("'", "'\\''")
end

-- Function to execute shell commands
local function run(command, hideCommand, requireSudo, hideOutput)
    hideCommand = hideCommand ~= nil and hideCommand or false
    hideOutput = hideOutput ~= nil and hideOutput or false
    requireSudo = requireSudo ~= nil and hideCommand or false

    local sudoPrefix = requireSudo and "sudo " or ""

    local handle = io.popen(sudoPrefix .. "sh -c '" .. escape_single_quotes(command) .. "'")
    local output = handle:read("*a")
    local success, _, exit_code = handle:close()

    if not success then
        logger.error("Command failed with exit code: " .. exit_code .. "\n" .. logger.add_whitespaces(command))
        return false, exit_code
    end

    output = logger.add_whitespaces(output)
    command = hideCommand and "" or command

    if hideCommand then
        if not hideOutput then
            logger.plain(output)
        end
    else
        logger.verbose("\27[35m" .. "Executing command " .. logger.colors.reset .. logger.colors.verbose .. command .. logger.colors.reset .. "\n" .. output)
    end

    return output, exit_code
end

function exec.run(command, hideCommand, requireSudo, hideOutput)
    return run(command, hideCommand, requireSudo, hideOutput)
end

function exec.sudo(command, hideCommand)
    return run(command, hideCommand, true)
end

function exec.silent(command, hideCommand, requireSudo)
    return run(command, hideCommand, requireSudo, true)
end

return exec

