import puppy
import std/json
import std/strutils
from os import fileExists
proc checkInternetConnection() =
  try:
    discard fetch("https://example.com/")
    echo("Internet connection is OK")
  except Exception as e:
    echo "Internet test has failed! Check your internet connection: ", e.msg
    quit(1)
proc checkIfValidDirectory() =
  if (fileExists("app.asar") and fileExists("build_info.json")):
    echo("Required files exist.")
  else:
    echo("Please place the updater in correct path (resources folder). Exiting.")
    quit(1)

when isMainModule:
  echo("ArmCord Updater")
  echo("Platform: " & hostOS)
  checkInternetConnection()
  checkIfValidDirectory() 
  var fetchVersion = fetch("https://armcord.xyz/latest.json")
  var latestVersion = parseJson(fetchVersion)["version"].getStr()
  var currentVersion = parseJson(readFile("build_info.json"))["version"].getStr()
  echo("Latest version: " & latestVersion)
  echo("Current version: " & currentVersion)
  var a = parseInt(latestVersion.replace(".", "")) # Remove the dots to compare
  var b = parseInt(currentVersion.replace(".", "")) # Remove the dots to compare
  if (a > b):
    echo("New version available!")
    echo("Getting the latest asar.")
    try:
      writeFile("app.asar", fetch("https://armcord.xyz/app.asar"))
      writeFile("build_info.json", fetch("https://armcord.xyz/latest.json"))
    except Exception as e:
      echo("Failed to download the latest asar: ", e.msg)
      quit(1)
    echo("Update installation has finished. You should be able to use the new version of ArmCord.")
  else:
    echo("No new version available.")