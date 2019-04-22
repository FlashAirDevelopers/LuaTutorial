--[[
CompileToByteCode.lua

Copyright (c) 2019 Toshiba Memory Corporation.

All sample code on this page is licensed under BSD 2-Clause License
https://github.com/FlashAirDevelopers/LuaTutorial/blob/master/LICENSE
]]

function luac_func(filename)
  local targets = filename
  local chunk = assert(loadfile(filename))
  local out = assert(io.open(targets..".out", "wb"))
  out:write(string.dump(chunk))
  out:close()
end                
luac_func("HelloWorld.lua")