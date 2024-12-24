#!/usr/bin/env lua

-- Get own directory
local self_dir_candidate= debug.getinfo(1, "S").source:sub(2)
local self_dir= self_dir_candidate:match("(.*/)")

-- Set Package Path to flowerpot's root
package.path = self_dir.. "?.lua;" .. package.path
package.path = package.path .. ";../../?.lua"

-- Imports
local logger = require("core.helper.logger")
local exec = require("core.helper.exec")

local docker = {}

local function install_docker ()
    exec.run("cd " .. FF_DIR .. " && bash " .. FF_DIR .. "scripts/install-docker.sh")
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
end

function docker.update ()
    local ver = exec.run("docker --version", true)

    if exec.silent("grep -qi 'microsoft' /proc/version", true) then
        return logger.warn("This is a WSL system. Skipping Docker installation.")
    end

    if not ver then
        logger.warn("Docker not installed or active, installing...")
        exec.run("sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin")
    end
end

function docker.kill ()
    exec.run("docker stop $(docker ps -aq) && docker rm $(docker ps -aq)", true)
end

function docker.clean ()
    exec.run("docker rmi $(docker images -q --filter=dangling=true); docker volume rm $(docker volume ls -q --filter=dangling=true); docker network rm $(docker network ls -q --filter=driver=bridge --filter=status=\"inactive\" | grep \"bridge\" | cut -d' ' -f1)", true)
end

function docker.run(method, ...)
    local args = {...}

    if type(docker[method]) == "function" then
        docker[method](table.unpack(args, 2))
    else
        logger.warn("Method " .. method .. " not found. Skipping.")
    end
end

return docker