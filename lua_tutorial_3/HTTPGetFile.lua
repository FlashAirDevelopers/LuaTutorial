result = fa.HTTPGetFile("https://flashair-developers.com/images/assets/flashairLogo_official_small.png", "logo.png")
if result ~= nil then
  print("Success! File downloaded.\n")
  --process the file
else
  print("Failure! File failed to download...\n")
end