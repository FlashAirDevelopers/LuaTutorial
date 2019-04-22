--[[
HelloWorld.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

print("Hello World!")
local file = io.open("Hello.txt", "a")
file:write("Hello There!\n")
file:close()