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
local logSysInfo = require("core.helper.logSysInfo")

-- install stuff

logger.title("Install basic stuff")
exec.run("sudo apt-get update -q")
exec.run("sudo apt-get upgrade -yqf --auto-remove")
exec.run("sudo apt-get clean -y")

exec.run("sudo apt-get install coreutils iptables nano curl wget net-tools git zip unzip tar sed htop util-linux lsb-release procps openssh-server ufw mawk gzip build-essential -y -m")

logSysInfo()

-- automatic weekly updates 
local updateScript = [[#!/bin/bash

# Log file
LOGFILE="/var/log/weekly-upgrade.log"

# Update package list
echo "Updating package list..." >> $LOGFILE
apt-get update >> $LOGFILE 2>&1

# Upgrade packages
echo "Upgrading packages..." >> $LOGFILE
apt-get upgrade -y >> $LOGFILE 2>&1

# Clean up
echo "Cleaning up..." >> $LOGFILE
apt-get autoremove -y >> $LOGFILE 2>&1
apt-get autoclean -y >> $LOGFILE 2>&1

echo "Upgrade completed at $(date)" >> $LOGFILE
]]

logger.info("Configuring automatic package upgrades...")
exec.run("echo \"" .. updateScript .. "\" | sudo tee /usr/local/bin/weekly-upgrade.sh > /dev/null", true)
exec.run("sudo chmod +x /usr/local/bin/weekly-upgrade.sh")
exec.run('(crontab -l | grep -v "/usr/local/bin/weekly-upgrade.sh"; echo "0 2 * * 0 /usr/local/bin/weekly-upgrade.sh") | crontab -')
exec.run('(echo "0 2 * * 0 /usr/local/bin/weekly-upgrade.sh") | sudo tee -a /etc/crontab > /dev/null')
logger.info("Weekly automatic package upgrades enabled. Visit '/var/log/weekly-upgrade.log' for logs.")