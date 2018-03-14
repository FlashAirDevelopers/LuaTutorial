function luac_func(filename)
  local targets = filename
  local chunk = assert(loadfile(filename))
  local out = assert(io.open(targets..".out", "wb"))
  out:write(string.dump(chunk))
  out:close()
end                
luac_func("HelloWorld.lua")