print("Hello World!")
local file = io.open("Hello.txt", "a")
file:write("Hello There!\n")
file:close()