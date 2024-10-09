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

local function convert_speed(speed)
    local value, unit = speed:match("([0-9.]+)%s*(%a+)")
    value = tonumber(value)
    if unit == "MB/s" and value >= 1024 then
        value = value / 1024
        unit = "GB/s"
    elseif unit == "GB/s" and value < 1 then
        value = value * 1024
        unit = "MB/s"
    end
    return value, unit
end

local function speed_test(filename)
    local fileSize = "8192"

    -- Write speed test
    local write_speed = exec.silent("dd if=/dev/zero of=" .. filename .. " bs=64K count=" .. fileSize .. " conv=fdatasync,notrunc 2>&1 | grep -o '[0-9.]* [MG]B/s'", true)
    local write_value, write_unit = convert_speed(write_speed)

    -- Read speed test
    local read_speed = exec.silent("dd if=" .. filename .. " of=/dev/null bs=64K count=" .. fileSize .. " 2>&1 | grep -o '[0-9.]* [MG]B/s'", true)
    local read_value, read_unit = convert_speed(read_speed)

    return write_value, write_unit, read_value, read_unit
end

local function measure_network_speed()
    logger.plain(logger.add_whitespaces("Testing Network Speed..."))
    exec.run("speedtest-cli --simple", true)
end

local function measure_disk_speed()
    logger.plain(logger.add_whitespaces("Testing Disk Speed..."))

    local total_write_speed = 0
    local total_read_speed = 0
    local num_tests = 10
    local w_unit = "?"
    local r_unit = "?"

    local testfile = "ff.speedtestfile"

    for i = 1, num_tests do
        local write_value, write_unit, read_value, read_unit = speed_test(testfile)
        total_write_speed = total_write_speed + write_value
        total_read_speed = total_read_speed + read_value
        w_unit = write_unit
        r_unit = read_unit
    end

    local avg_write_speed = total_write_speed / num_tests
    local avg_read_speed = total_read_speed / num_tests

    logger.plain(
        logger.add_whitespaces(
            string.format("Average Write Speed: %.2f %s/s", avg_write_speed, w_unit)
        )
    )
    logger.plain(
        logger.add_whitespaces(
            string.format("Average Read Speed: %.2f %s/s", avg_read_speed, r_unit)
        )
    )
    logger.plain("")

    os.remove(testfile)
end

local function logSysInfo()
    logger.title("System Information:")

    logger.plain(logger.add_whitespaces("\n# Distro: "))
    exec.run("lsb_release -ds", true)
    
    logger.plain(logger.add_whitespaces("# RAM & CPU: "))
    exec.run([[
        vmstat 1 1 | awk 'NR==3 {
        ram_total_gb = ($4 + $5 + $6) / 1024 / 1024
        ram_used_gb = ram_total_gb - ($4 / 1024 / 1024)
        swap_gb = $3 / 1024 / 1024
        cpu_usage = 100 - $15
        print "RAM total: " sprintf("%.2f", ram_total_gb) " GB"
        print "RAM used: " sprintf("%.2f", ram_used_gb) " GB"
        print "Swap: " sprintf("%.2f", swap_gb) " GB"
        print "CPU usage: " cpu_usage "%"}'
    ]], true)

    exec.run([[
        echo "# DISKS:" & lsblk -o NAME,SIZE,MOUNTPOINT | grep -v 'loop' | while read -r line; do
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

    measure_disk_speed()

    exec.run([[
        echo "# PUBLIC IP:" & ip -4 addr show dev $(ip route show default | awk '/default/ {print $5}') | grep inet | awk '{print $2}' | awk -F'/' '{print $1}'
    ]], true)

    measure_network_speed()
end

return logSysInfo