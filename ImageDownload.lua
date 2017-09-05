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