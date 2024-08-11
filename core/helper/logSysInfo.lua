#!/usr/bin/env lua

local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")
package.path = current_dir .. "?.lua;" .. package.path

-- Import logger.lua
local logger = require("logger")
local exec = require("exec")

local function logSysInfo()
    logger.title("System Information:")
    exec.run("lsb_release -ds", true)
    exec.run([[vmstat 1 1 | awk 'NR==3 { 
        # Convert memory values from kilobytes to gigabytes
        mem_free_gb = $4 / 1024 / 1024
        mem_buff_gb = $5 / 1024 / 1024
        mem_cache_gb = $6 / 1024 / 1024
        print "RAM: swpd=" $3 "kB, free=" sprintf("%.2f", mem_free_gb) "GB, buff=" sprintf("%.2f", mem_buff_gb) "GB, cache=" sprintf("%.2f", mem_cache_gb) "GB"; 
        print "CPU: user=" $13 ", sys=" $14 ", idle=" $15 ", wa=" $16 ", st=" $17
    }']], true)

    exec.run([[
        echo "DISKS:" & lsblk -o NAME,SIZE,MOUNTPOINT | grep -v 'loop' | while read -r line; do
            device=$(echo "$line" | awk '{print $1}')
            size=$(echo "$line" | awk '{print $2}')
            
            if [ "$device" != "NAME" ]; then
                # Check if the device is mounted
                mountpoint=$(echo "$line" | awk '{print $3}')
                if [ -n "$mountpoint" ]; then
                    avail=$(df -h | grep "/dev/$device" | awk '{print $4}')
                    echo "$device: $size total, $avail free"
                else
                    echo "$device: $size total, not mounted"
                fi
            fi
        done
    ]], true)

    exec.run([[
        echo "PUBLIC IP:" & ip -4 addr show dev $(ip route show default | awk '/default/ {print $5}') | grep inet | awk '{print $2}' | awk -F'/' '{print $1}'
    ]], true)
end

return logSysInfo