--[[
GoogleDriveUpload.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

-- Basic account info
local client_id = "{Your full client ID}"
local client_secret = "{Your client secret}"
local refresh_token = "{Your refresh token}"
-- For refresh
local scope = "https://docs.google.com/feeds"
local response_type = "code"
local access_type = "offline"

local function getAuth()
  -- Set our message
  local mes="client_id="..client_id
  mes=mes.."&client_secret="..client_secret
  mes=mes.."&refresh_token="..refresh_token
  mes=mes.."&grant_type=refresh_token"

  local length = string.len(mes)
  print("Sending: ["..mes.."]")
  print "\n"
  b, c, h = fa.request{
    url = "https://accounts.google.com/o/oauth2/token",
    headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Content-Length"] = length,
    },
    method = "POST",
    body=mes,
  }

  local tempTable = {}

  tempTable = cjson.decode(b)

  access_token = tempTable["access_token"]
end

local function uploadTest(token)
  filePath="testfile.jpg"
  local fileSize = lfs.attributes(filePath,"size")
  b, c, h = fa.request{
    url = "https://www.googleapis.com/upload/drive/v2/files",
    headers = {
      ["Content-Type"] = "image/jpeg",
      ["Content-Length"] = fileSize, -- calculate file size
      ["authorization"] = "Bearer "..token,
      ["uploadType"]="media"
    },
    method = "POST",
    --NOTE: You probably want to set your own file here,
    --or maybe even pass it as a parameter!
    file=filePath
  }
end

getAuth()
uploadTest(access_token)