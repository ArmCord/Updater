import std/httpclient
import std/json
import std/strutils

var client = newHttpClient(timeout = 4000)
proc onProgressChanged(total, progress, speed: BiggestInt) =
  echo("Downloaded ", progress, " of ", total)
  echo("Current rate: ", speed div 1000, "kb/s")
proc checkInternetConnection() =
  try:
    discard client.getContent("https://example.com/")
    echo("Internet connection is OK")
  except Exception as e:
    echo "Internet test has failed! Check your internet connection: ", e.msg
    quit(1)
when isMainModule:
  echo("ArmCord Updater")
  echo("Platform: " & hostOS)
  checkInternetConnection()
  var fetchVersion = client.getContent("https://armcord.xyz/latest.json")
  var latestVersion = parseJson(fetchVersion)["version"].getStr()
  var currentVersion = parseJson(readFile("build_info.json"))["version"].getStr()
  echo("Latest version: " & latestVersion)
  echo("Current version: " & currentVersion)
  var a = parseInt(latestVersion.replace(".", "")) # Remove the dots to compare
  var b = parseInt(currentVersion.replace(".", "")) # Remove the dots to compare
  if (a > b):
    echo("New version available!")
    echo("Getting the latest asar.")
    client.onProgressChanged = onProgressChanged
    writeFile("app.asar", client.getContent("https://armcord.xyz/app.asar"))
  else:
    echo("No new version available.")