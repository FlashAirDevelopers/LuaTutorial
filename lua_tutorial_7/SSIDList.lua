--[[
SSIDList.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

--[[
This script will scan for available WiFi networks,
and output their SSIDs to a file.
]]--

local logfile = "ssidList.txt"

count = fa.Scan()
-- Open the log file
local outfile = io.open(logfile, "w")

-- Write a header
outfile:write("SSID list: \n")

--Note that the ssids start at 0, and go to (count-1)
for i=0, (count-1), 1 do
	ssid, other = fa.GetScanInfo(i)
	outfile:write(i..": "..ssid.."\n")
end