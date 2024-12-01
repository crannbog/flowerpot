#!/usr/bin/env lua

-- Get flowerpot's directory
local flowerpot_dir_candidate = debug.getinfo(1, "S").source:sub(2)
local flowerpot_dir = flowerpot_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = flowerpot_dir .. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Imports
local logger = require("core.helper.logger")
local exec = require("core.helper.exec")

local docker = {}

local function install_docker ()
    logger.title(flowerpot_dir .. " + " .. flowerpot_dir_candidate)
    exec.run("cd " .. flowerpot_dir .. " && bash " .. flowerpot_dir .. "scripts/install-docker.sh")
end

function docker.install ()
    local ver = exec.run("docker --version", true)

    if exec.silent("grep -qi 'microsoft' /proc/version", true) then
        return logger.warn("This is a WSL system. Skipping Docker installation.")
    end

    if not ver then
        logger.warn("Docker not installed or active, installing...")
        install_docker()
    end
    
    -- 
end

return docker