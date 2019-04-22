--[[
ImageDownload.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

--HTTP request
result = fa.HTTPGetFile("https://flashair-developers.com/images/assets/flashairLogo_official_small.png", "logo.png")
print("<!DOCTYPE html>")
print("<html>")
print("<body><center>")
print("<h2>Hello HTML!</h2>")
if result ~= nil then
  --Display the image
  print("<img src=\"logo.png\" alt=\"FlashAir Developers Logo\">")
else
  print("File failed to download...")
end
print("</body>")
print("</html>")