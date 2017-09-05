--[[
FlashAir Lua Dropbox example.

This script uploads and files in a directory to dropbox, using oauth2.
It will store the access token in dropbox_token.txt
--]]
local tokenfile		= "/dropbox_token.txt" 	-- Where to log output on the FA
local folder 		= "/Upload" 		-- What folder to upload files from
local app_key		= "btbjfXxXxXxXxXx"		-- Your Dropbox app's key
local app_secret	= "4k79gXxXxXxXxXx"		-- Your Dropbox app's secret

--NOTE: Remember to authorize your app!
local auth_code 	= "XrfRXkfTNcXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxX" -- authorization code!

--[[
The following function encodes data to base64, which is required to send requests
to dropbox that use the applications key and secret (ex: getting the auth token)
--]]
local base64_table='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64_enc(data)
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return base64_table:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

--[[
requestToken(app key, app secret, authorization code)
requests the oath2 token, using fa.request().
returns the token, or nil on a failure.
--]]
local function requestToken(key, secret, auth_code)
	--Combine our app's key and secret'
	appKey = key..":"..secret

	--Request a token
	message = "grant_type=authorization_code&code="..auth_code
	b, c, h = fa.request{
		url = "https://api.dropbox.com/1/oauth2/token",
		method = "POST",
		headers = {["Authorization"] = "Basic " .. (base64_enc(appKey)),
		["Content-Length"] = string.len(message),
		["Content-Type"] = "application/x-www-form-urlencoded"},
		body = message
	}

	--Decode the response body (json format)
	response = cjson.decode(b)
	access_token = response["access_token"]
	if access_token ~= nil then
		return access_token
	else
		error = response["error_description"]
		print("Failed to get access token. Error: "..c..": "..error)
		return nil
	end
end

--[[
These functions simply load or save the access token to/from a file (tokenfile).
--]]
local function saveToken(access_token)
	local file = io.open(tokenfile, "w" )
	file:write(access_token)
	io.close(file)
end
local function loadToken()
	local file = io.open(tokenfile, "r" )
	access_token = nil
	if file then
		access_token = file:read( "*a" )
	end
	return access_token
end

--[[
	uploadFile(folder, file name, access token)
	Attempts to upload a file to dropbox!
--]]
local function uploadFile(folder, file, access_token)
	file_path=folder .. "/" .. file
	--get the size of the file
	local filesize = lfs.attributes(file_path,"size")
	if filesize ~= nil then
		print("Uploading "..file_path.." size: "..filesize)
	else
		print("Failed to find "..file_path.."... something wen't wrong!")
		return
	end

	--Upload!
	b, c, h = fa.request{
		url = "https://api-content.dropbox.com/1/files_put/dropbox/"..file.."?overwrite=true",
		method = "PUT",
		headers = {["Authorization"] = "Bearer "..access_token,
		["Content-Length"] = filesize},
		file=file_path,
		bufsize=1460*10
	}

	print(c)
	print(b)

end

--Script starts

--Attempt to load a token from the file
token = loadToken()

--See if we loaded one, if not request one
if token == nil then
	--Request an access token
	print("No token found, attempting to request one...")
	token = requestToken(app_key, app_secret, auth_code)

	--Was it successful?
	if token == nil then
		print("Failed to request token, do you need to authorize?")
		print("Auth url: https://www.dropbox.com/1/oauth2/authorize?client_id="..app_key.."&response_type=code")
	else
		print("New token: "..token)
		saveToken(token)
	end

end

--Before continuing, make sure we have an access token
if token ~= nil then
	print("INIT, with token: "..token)
	-- For each file in folder...
	for file in lfs.dir(folder) do
		-- Get that file's attributes
		attr = lfs.attributes(folder .. "/" .. file)

		-- Don't worry about directories (yet)
		if attr.mode == "file" then
			--Attempt to upload the file!
			uploadFile(folder, file, token)
		end
	end
end