--Read the FlashAir config file, store it in a table
local function loadConfig()
	local file = io.open("/SD_WLAN/CONFIG", "r" )
	config = {}
	for line in file:lines() do
		--Split the config file into variables and values
		--ie: APPMODE=5
		var, value = line:match("([^,]+)=([^,]+)")
		if var ~= nil and value ~= nil then
			config[var] = value
		end
	end
	return config
end

--Returns a list of files in a directory, as well as their size
local function getfileSize(path)
	size=0
	for file in lfs.dir(path) do
		attr = lfs.attributes(path.."/"..file)
		if attr ~= nil and attr.mode == "file" then
			size = size + math.floor( attr.size / 1024 * math.pow( 10, 1 ) ) / math.pow( 10, 1 )
		end
	end
	return size
end

local function getfileList(path)
	file_list = {}
	for file in lfs.dir(path) do
		attr = lfs.attributes(path.."/"..file)
		file_list[file] = getfileSize(path.."/"..file)
	end
	return file_list
end

--Recursively counts the number of files in a directory (not including folders)
local function countFiles(path)
	--print("Counting: "..path)
	count=0
	for file in lfs.dir(path) do
		attr = lfs.attributes(path.."/"..file)
		if attr ~= nil and attr.mode == "file" then
			count = count +1
		end
		if attr ~= nil and attr.mode == "directory" then
			count = count + countFiles(path.."/"..file)
		end
	end
	return count
end

reloadTime = "60" --How often (in seconds) the status page should update.
monitorDir = "/DCIM" --What directory to monitor

--load the config file
config_table=loadConfig()
file_count=countFiles(monitorDir)
file_list=getfileList(monitorDir)

print("<!DOCTYPE html>")
print("<html>")
--Set the page to reload every x seconds
print("<meta http-equiv=\"refresh\" content=\""..reloadTime.."\" />")
print("<body><center>")
if config_table["APPNAME"] ~= nil then
	print("<h2>"..config_table["APPNAME"].." Status Page</h2>")
else
	print("<h2>FlashAir Status Page</h2>")
end

if config_table["APPMODE"] ~= nil and config_table["APPSSID"] ~= nil and config_table["VERSION"]  ~= nil then
	print("<b>APPMODE:</b> "..config_table["APPMODE"].."<b>SSID:</b> <i>"..config_table["APPSSID"].."</i>")
	print("<br>")
	print("<b>Version: </b>"..config_table["VERSION"])

else
	print("<b>Error loading CONFIG file!</b>")
end
print("<br><br>")
print("<h2>"..monitorDir.."</h2>")
print("<div>")
for file,size in pairs(file_list) do
	if file ~= "" and size ~= "" then
		print("<a href="..monitorDir.."/"..file..">"..file.."</a>: "..size.."kb<br>")
	end
end
print("</div>")
print("Total files: "..file_count)
print("</body>")
print("</html>")
