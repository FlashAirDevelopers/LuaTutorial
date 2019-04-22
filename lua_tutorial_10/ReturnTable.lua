--[[
ReturnTable.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

local function _foo()
  print("Hello World!")
end                 
return {
  foo=_foo
}