local logfile   = "/FTPLog.txt"     -- Log file created in FlashAir
local folder    = "/Upload"         -- Folder to upload file is located
local server    = "192.168.1.1"     -- IP address of FTP server
local serverDir = "/LuaTutorial"    -- FTP server upload folder
local user      = "ftp"             -- FTP user name
local passwd    = "abc123"          -- FTP password

-- Assemble our FTP command string
-- example: "ftp://user:pass@192.168.1.1/LuaTutorial"
local ftpstring = "ftp://"..user..":"..passwd.."@"..server..serverDir

-- Open the log file
local outfile = io.open(logfile, "w")

-- Write a header
outfile:write("File list: \n")

-- For each file in folder...
for file in lfs.dir(folder) do
    -- Get that file's attributes
    attr = lfs.attributes(folder .. "/" .. file)
    print( "Found "..attr.mode..": " .. file )

    -- Don't worry about directories (yet)
    if attr.mode == "file" then
        --Attempt to upload the file!
        --ex ftp("put", "ftp://user:pass@192.168.1.1/LuaTutorial/test.jpg", "Upload/test.jpg")
        response = fa.ftp("put", ftpstring .. "/" .. file, folder .. "/" .. file)

        --Check to see if it worked, and log the result!
        if response ~= nil then
            print("Success!")
            outfile:write("" .. file .. "... Success!\n")
        else
            print("Fail :(")
            outfile:write("" .. file .. "... Fail :(\n")
        end
    end
end

--Close our log file
outfile:close()