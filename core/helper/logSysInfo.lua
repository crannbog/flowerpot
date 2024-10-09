#!/usr/bin/env lua

local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")
package.path = current_dir .. "?.lua;" .. package.path

-- Import logger.lua
local logger = require("logger")
local exec = require("exec")

local function measure_speed()
    logger.plain(logger.add_whitespaces("Testing Network Speed..."))
    exec.run("speedtest-cli --simple", true)
end

local function logSysInfo()
    logger.title("System Information:")

    logger.plain(logger.add_whitespaces("\n# Distro: "))
    exec.run("lsb_release -ds", true)
    
    logger.plain(logger.add_whitespaces("# RAM & CPU: "))
    exec.run([[
        vmstat 1 1 | awk '\''NR==3 {
        ram_total_gb = ($4 + $5 + $6) / 1024 / 1024
        ram_used_gb = ram_total_gb - ($4 / 1024 / 1024)
        swap_gb = $3 / 1024 / 1024
        cpu_usage = 100 - $15
        print "RAM total: " sprintf("%.2f", ram_total_gb) " GB"
        print "RAM used: " sprintf("%.2f", ram_used_gb) " GB"
        print "Swap: " sprintf("%.2f", swap_gb) " GB"
        print "CPU usage: " cpu_usage "%"}'\''
    ]], true)

    exec.run([[
        echo "# DISKS:" & lsblk -o NAME,SIZE,MOUNTPOINT | grep -v '\''loop'\'' | while read -r line; do
            device=$(echo "$line" | awk '\''{print $1}'\'')
            size=$(echo "$line" | awk '\''{print $2}'\'')
            
            if [ "$device" != "NAME" ]; then
                # Check if the device is mounted
                mountpoint=$(echo "$line" | awk '\''{print $3}'\'')
                if [ -n "$mountpoint" ]; then
                    avail=$(df -h | grep "/dev/$device" | awk '\''{print $4}'\'')
                    echo "$device: $size total, $avail free"
                else
                    echo "$device: $size total, not mounted"
                fi
            fi
        done
    ]], true)

    exec.run([[
        echo "# PUBLIC IP:" & ip -4 addr show dev $(ip route show default | awk '\''/default/ {print $5}'\'') | grep inet | awk '\''{print $2}'\'' | awk -F'\''/'\'' '\''{print $1}'\''
    ]], true)

    measure_speed()
end

return logSysInfo