--[[
This script will scan for a specific network, and if it sees it
will connect... then trigger a dropbox uploading script!
It logs to a file.
]]--

local logfile 	= "wifiConnect.txt"
local SSID 	= "VITP_Open" -- SSID to connect to
local PASSWORD 	= "" --A blank password should be used for an open network
local uploader	= "DropboxUpload.lua"

-- Open the log file
local outfile = io.open(logfile, "w")

while true do

	-- Initiate a scan
	count = fa.Scan(SSID)
	--count = fa.Scan()
	found=0
	--See if we found it
	if count > 0 then
		--ssid, other = fa.GetScanInfo(0) --Should return SSID provided
		for i=0, (count-1), 1 do
			found_ssid, other = fa.GetScanInfo(i)
			print(SSID.."|"..found_ssid)
			if SSID == found_ssid then
				--We did!
				print("Found: "..SSID.."... attempting to connect.")
				outfile:write("Found: "..SSID.."... attempting to connect.")
				found=1
				break
			end
		end
	end

	if found == 1 then break end --If we found it, stop looping
end

--We should only get here if the above loop found the network
--fa.Connect has no return, but if the SSID and password are correct it should work.
fa.Connect(SSID, PASSWORD)

--Execute the upload script
dofile(uploader)
--Close our log file
outfile:close()
