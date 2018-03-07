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
requestToken(app key, app secret, authorization code)
requests the oath2 token, using fa.request().
returns the token, or nil on a failure.
--]]
local function requestToken(key, secret, auth_code)
	--Request a token
	message = "grant_type=authorization_code&code="..auth_code.."&client_id="..key.."&client_secret="..secret
	b, c, h = fa.request{
		url = "https://api.dropboxapi.com/oauth2/token",
		method = "POST",
		headers = {["Content-Length"] = string.len(message),
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
		url = "https://content.dropboxapi.com/2/files/upload",
		method = "POST",
		headers = {["Authorization"] = "Bearer "..access_token,
		["Content-Length"] = filesize,
		["Content-Type"] = "application/octet-stream",
		["Dropbox-API-Arg"] = '{"path":"'..file_path..'","mode":{".tag":"overwrite"}}'},
		body = "<!--WLANSDFILE-->",
		bufsize = 1460*10,
		file=file_path
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
		print("Auth url: https://www.dropbox.com/oauth2/authorize?client_id="..app_key.."&response_type=code")
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