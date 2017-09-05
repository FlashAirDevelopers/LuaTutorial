result = fa.HTTPGetFile("http://somewhere/secretfile.txt", "secretfile.txt", "aUser", "passw0rd")
if result ~= nil then
  print("Success! File downloaded.\n")
  --process the file
else
  print("Failure! File failed to download...\n")
end