--LUA_RUN_SCRIPT=/lua/fb_auto_up.lua
app_access_token = ""
app_secret = ""
app_id = ""
lastupload = ""
album_name = ""
album_id = nil


local function readConfig(file_name)
    for line in io.lines(file_name) do
        local s, e, cap = line:find("=")
        if (s ~= 1 or cap ~= "") then
            local key = line:sub(1, s - 1)
            local val = line:sub(e + 1)
            if (key == "lastupload") then
                lastupload = val
            elseif (key == "album_name") then
                album_name = val
            elseif (key == "album_id") then
                album_id = val
            elseif (key == "access_token") then
                user_access_token = val
            elseif (key == "app_access_token") then
                app_access_token = val
            elseif (key == "app_secret") then
                app_secret = val
            elseif (key == "app_id") then
                app_id = val
            end
        end
    end
end


local function writeConfig(cfg_name, _dir, _file)
    local wFile = io.open(cfg_name, "w")
    if (wFile == nil) then return end

    lastupload = _dir:sub(1, 3).._file:sub(5, 8)
    wFile:write("lastupload="..lastupload.."\n")
    wFile:write("album_name="..album_name.."\n")
    wFile:write("album_id="..album_id.."\n")
    io.close(wFile)
end


local function getInfo()
    readConfig("/lua/lastupload.cfg")
    readConfig("/lua/fb_access_token")
    readConfig("/lua/facebook.cfg")
end


local function createAlbum(_name, _message)
    local req = {}
    req["url"] = 'https://graph.facebook.com/v2.1/me/albums?access_token='..user_access_token
        ..'&name='..string.gsub (_name, " ", "+")
        ..'&message='..string.gsub (_message, " ", "+")
        ..'&privacy=%7B%22value%22%3A+%22SELF%22%7D'
    req["method"] = 'POST'
    req["headers"] = {Connection = "close"}

    local b,c,h = fa.request(req)
    if (c ~= 200) then
        print(h, b)
        return nil
    end
    req = nil

    c, h = nil
    local cjson = require("cjson")
    local res = cjson.decode(b)
    collectgarbage()
    return res["id"]
end


local function uploadFile(filePath, _album_id)
    local boundary = '--bnfDxpKY69NKk'
    local headers = {}
    local place_holder = '<!--WLANSDFILE-->'

    headers['Connection'] = 'close'
    headers['Content-Type'] = 'multipart/form-data; boundary="'..boundary..'"'

    local body = '--'..boundary..'\r\n'
        ..'Content-Disposition: form-data; name="source"; filename="'
        ..filePath..'"\r\n'
        ..'Content-Type: image/jpeg\r\n\r\n'
        ..'<!--WLANSDFILE-->\r\n'
        .. '--' .. boundary .. '--\r\n'

    headers['Content-Length'] =
        lfs.attributes(filePath, 'size')
        + string.len(body)
        - string.len(place_holder)

    local args = {}
    args["url"] = 'https://graph.facebook.com/v2.1/'
            .._album_id..'/photos?access_token='
            ..user_access_token
            ..'&message='..filePath
    args["method"] = "POST"
    args["headers"] = headers
    args["body"] = body
    args["file"] = filePath
    args["bufsize"] = 1460*10
    local b,c,h = fa.request(args)
    b, h = nil
    collectgarbage()
    if (c ~= 200) then
        print(h, b)
        return nil
    end
    return c
end


local function autoUpload()
    local lastPhoto = 0
    local lastDirectory = 0
    if (#lastupload > 0) then
        lastDirectory = tonumber(lastupload:sub(1, 3))
        lastPhoto = tonumber(lastupload:sub(4))
    end

    for aDirectory in lfs.dir("/DCIM") do
        local _dir_id = tonumber(aDirectory:sub(1, 3))
--        print("DIR:"..aDirectory, lfs.attributes("/DCIM/"..aDirectory, "modification"))
        if (_dir_id ~= nil and _dir_id >= lastDirectory) then
            for aFile in lfs.dir("/DCIM/"..aDirectory) do
                local filePath = "/DCIM/"..aDirectory.."/"..aFile
                if (lfs.attributes(filePath, "mode") ~= "file") then
                    goto continue
                end

                local photoNum = tonumber(aFile:sub(5, 8))
                if (lastPhoto >= photoNum ) then
                    goto continue
                else
                    lastPhoto = photoNum
                end

                local mod_val = lfs.attributes(filePath, "modification")
                local yyyy = 1980 + bit32.extract(mod_val, 25, 7)
                local mm = bit32.extract(mod_val, 21, 4)
                local dd = bit32.extract(mod_val, 16, 5)
                local mod_date = yyyy.."-"..mm.."-"..dd
                yyyy, mm, dd = nil

                if (album_name ~= mod_date or album_id == nil) then -- "YYYY-M-D"
                    album_name = mod_date
                    album_id = createAlbum (mod_date, "Auto Upload via FlashAir")
                end

--                print(album_name, album_id, mod_date)
--                print(filePath)

                if (album_id ~= nil) then
                    local c = uploadFile(filePath, album_id)
                    if c == 200 then
--                        print(aFile, mod_date)
                        writeConfig("/lua/lastupload.cfg", aDirectory, aFile)
                    end
                end

                ::continue::
            end
--            print(aDirectory..":end")
            lastPhoto = 0
        end
    end
end


local function waitWlanConnect()
    while 1 do
        local res = fa.ReadStatusReg()
        local a = string.sub(res, 13, 16)
        a = tonumber(a, 16)
        if (bit32.extract(a, 15) == 1) then
            print("connect")
            break
        end
        if (bit32.extract(a, 0) == 1) then
            print("mode Bridge")
            break
        end
        if (bit32.extract(a, 12) == 1) then
            print("mode AP")
            break
        end
        sleep(2000)
    end
end

-- Main script
collectgarbage("setstepmul", 24576)
waitWlanConnect()
getInfo()
collectgarbage()
print("count"..collectgarbage("count"))

if (#arg == 1) then
    autoUpload()
    print("end")
else
    while true do
        autoUpload()
        collectgarbage()
        sleep(5000)
    end
end
