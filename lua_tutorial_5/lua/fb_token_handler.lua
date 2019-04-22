--[[
fb_token_handler.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

local mod = {}
local configFilePath = "/lua/facebook.cfg"


local function readConfig(file_name)
    local config = {}
    for line in io.lines(file_name) do
        local s, e, cap = line:find("=")
        if (s ~= 1 or cap ~= "") then
            local key = line:sub(1, s - 1)
            local val = line:sub(e + 1)
            config[key] = val
        end
    end
    return config
end


local function module_init()
    local config = readConfig(configFilePath)
    mod["app_access_token"] = config.app_access_token
    mod["app_id"] = config.app_id
    mod["app_secret"] = config.app_secret
    mod["token_fullpath"] = config.token_fullpath

    local token = readConfig(mod.token_fullpath)
    mod["user_access_token"] = token.access_token
end

module_init()
return mod
