#!/usr/bin/env lua

local current_file_path = debug.getinfo(1, "S").source:sub(2)
local current_dir = current_file_path:match("(.*/)")
package.path = current_dir .. "?.lua;" .. package.path

-- Logger module
local logger = {}

logger.colors = {
    verbose = "\27[2m",
    highlight = "\27[35m",
    info = "\27[36m",
    warn = "\27[33m",
    error = "\27[31m",
    reset = "\27[0m"
}

-- Log levels
logger.levels = {
    plain =   {name = "PLN", color = logger.colors.reset },
    verbose = {name = "VEB", color = logger.colors.verbose },  -- White
    info =    {name = "INF", color = logger.colors.info },  -- cyan
    warn =    {name = "WRN", color = logger.colors.warn },  -- Yellow
    error =   {name = "ERR", color = logger.colors.error }   -- Red
}

-- Current log level
logger.current_level = logger.levels.verbose

-- Function to set the log level
function logger.set_level(level)
    logger.current_level = level
end

-- Function to get the current timestamp
local function get_timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Function to log a message
local function log(level, message)
    if level == logger.levels.verbose or 
       level == logger.levels.info or 
       level == logger.levels.warn or 
       level == logger.levels.error then
        if logger.current_level == logger.levels.verbose or
           (logger.current_level == logger.levels.info and level ~= logger.levels.verbose) or
           (logger.current_level == logger.levels.warn and (level == logger.levels.warn or level == logger.levels.error)) or
           (logger.current_level == logger.levels.error and level == logger.levels.error) then
            print(string.format(logger.colors.reset .. "%s%s[%s]\27[0m %s\27[0m", level.color, get_timestamp(), level.name, message))
        end
    elseif level == logger.levels.plain then
        print(string.format("%s%s", level.color, message))
    else
        error("Invalid log level")
    end
end

-- Public log functions
function logger.verbose(message)
    log(logger.levels.verbose, message)
end

function logger.info(message)
    log(logger.levels.info, message)
end

function logger.warn(message)
    log(logger.levels.warn, message)
end

function logger.error(message)
    log(logger.levels.error, message)
end

function logger.plain(message)
    log(logger.levels.plain, message)
end

function logger.title(message)
    local leng = #message + 4
    local line = string.rep("=", leng)

    log(logger.levels.plain, "\n\27[32m  " .. line .. "\n  * " .. logger.colors.reset .. message .. "\27[32m *\n  " .. line)
end

function logger.add_whitespaces(input)
    local n_spaces = string.rep(" ", 2)
    return input:gsub("([^\r\n]+)", n_spaces .. "%1")
end

return logger