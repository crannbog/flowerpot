#!/usr/bin/env lua

-- Get own directory
local self_dir_candidate= debug.getinfo(1, "S").source:sub(2)
local self_dir= self_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = self_dir.. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Get the current file's directory
local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")

-- Add the helpers/ directory to package.path so we can find logger.lua
package.path = current_dir .. "?.lua;" .. package.path

FF_DIR = current_dir; 

-- imports

local logger = require("core.helper.logger")
local exec = require("core.helper.exec")
local info = require("core.helper.logSysInfo")
local managerModule = require("manager.manager")
local configModule = require("core.config.config")
local installDocker = require("core.installer.install-docker")
local teleportModule = require("teleport.teleport")


local fp = {}

local function check_and_install_git()
    -- Check if Git is installed by running 'git --version'
    local result = exec.run("git --version", true)

    -- If the result contains 'git version', it means git is installed
    if result and string.match(result, "git version") then
        return
    else
        logger.verbose("Git is not installed. Installing Git...")
        
        -- Install Git using apt-get
        exec.sudo("apt-get update && apt-get install -y git", true)
        return
    end
end

local function check_is_repo()
    local result = exec.run("cd " .. FF_DIR .. "&& git status", true)

    if result and string.match(result, "fatal") then
        logger.info("Fresh/manual install detected, not a git repository. Initializing...")
        exec.run("git init -y -b stable")
        exec.run("git remote add origin git@github.com:crannbog/flowerpot.git")
    end
end

function fp.test()
    logger.info("Flowerpot is working. Noot Noot.")
    configModule.hello()
end

function fp.update()
    check_and_install_git()
    check_is_repo()
    logger.info("Updating flowerpot in " .. current_dir)
    exec.run("cd " .. current_dir .. " && git pull")
end

function fp.info()
    info()
end

function fp.relog()
    exec.run("sudo -k su -l $USER &")
end

function fp.docker(...)
    local args = {...}
    installDocker.run(args[1])
end

function fp.manager(...)
    local args = {...}
    managerModule.run(args[1])
end

function fp.teleport(...)
    teleportModule.run(...)
end

-- export the fp module

return fp