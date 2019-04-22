--[[
fb_get_token.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

local userToken = require("/lua/fb_token_handler")


local function hasValidToken(t)
    local b, c, h = fa.request {
        url = 'https://graph.facebook.com/debug_token?input_token='
            ..t.user_access_token..'&access_token='
            ..t.app_access_token,
        headers = {Connection = 'close'}
    }
    if (c == 200) then
        local cjson = require("cjson")
        local res = cjson.decode(b)
        cjson = nil
        if (res.error ~= nil) then
            t.message = res.error.message
        else
            t.long_term = res.data.issued_at
            if (res.data.error ~= nil) then
                t.message = res.data.error.message
            else
                t.message = res.data.message
            end
        end
        return res.data.is_valid
    else
        t.message = b
        return false
    end
end


local function getLongtermToken(t)
  local b, c, h = fa.request {
    url = 'https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token'
      ..'&client_id='..t.app_id
      ..'&client_secret='..t.app_secret
      ..'&fb_exchange_token='..t.user_access_token,
    headers = {Connection = 'close'}
  }

  if (c == 200) then
    local s, e = b:find("&")
    local longtermToken = b:sub(1, s - 1)
    local file = io.open( t.token_fullpath, "w" )
    file:write( longtermToken )
    io.close( file )
    file = nil

    s, e = longtermToken:find("=")
    t.user_access_token = longtermToken:sub(e+1, #longtermToken)
  end
end


local function showAuthorizationURL(mes)
    local html = [[
<html><body><a href="https://www.facebook.com/dialog/oauth?response_type=token
&scope=publish_actions, user_photos&client_id=%s
&redirect_uri=http://flashair.local/lua/facebook.html">%s
</a></body></html>
]]

    if (mes == nil) then mes = "Please Facebook authorization" end
    print(string.format(html, userToken.app_id, mes))
end


if (hasValidToken(userToken) == false) then
    showAuthorizationURL(userToken.message)
    return
end

if (userToken.long_term == nil) then
    getLongtermToken(userToken)
end

if (userToken.user_access_token == nil) then
    print("!!!!! error: not found token.")
else
    print("user access token:\n"..userToken.user_access_token)
end
