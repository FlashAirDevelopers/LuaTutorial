--[[
HTTPGetFile.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

result = fa.HTTPGetFile("https://flashair-developers.com/images/assets/flashairLogo_official_small.png", "logo.png")
if result ~= nil then
  print("Success! File downloaded.\n")
  --process the file
else
  print("Failure! File failed to download...\n")
end