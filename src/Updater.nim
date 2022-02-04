import puppy
import std/json
import std/strutils
import std/os
import std/md5
var attempts = 1
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
proc downloadUpdate(endpoint:string) =
    echo("New version available!")
    echo("Getting the latest asar.")
    try:
      moveFile("app.asar", "app.asar.old")
      moveFile("build_info.json", "build_info.json.old")
      writeFile("app.asar", fetch(endpoint & "app.asar"))
      writeFile("build_info.json", fetch(endpoint & "latest.json"))
    except Exception as e:
      echo("Failed to download the latest asar: ", e.msg)
      moveFile("app.asar.old", "app.asar")
      moveFile("build_info.json.old", "build_info.json")
      quit(1)
    echo ("Downloaded the latest asar. Checking checksums")
    if (parseJson(readFile("build_info.json"))["md5"].getStr() == getMD5(readFile("app.asar"))):
      echo("Checksums match..")
    else:
      attempts = attempts + 1
      if (attempts > 3):
        moveFile("app.asar.old", "app.asar")
        moveFile("build_info.json.old", "build_info.json")
        echo("Checksums didn't match after 2 attempts to download the update. Reverting the update. Exiting.")
        quit(1)
      else:
        echo("Checksums do not match. Update failed! Retrying")
        downloadUpdate(endpoint)
    removeFile("app.asar.old")
    removeFile("build_info.json.old")
    echo("Update installation has finished. You should be able to use the new version of ArmCord.")
when isMainModule:
  echo("ArmCord Updater")
  echo("Platform: " & hostOS)
  checkInternetConnection()
  checkIfValidDirectory() 
  var endpoint = parseJson(readFile("build_info.json"))["update_endpoint"].getStr()
  var fetchVersion = fetch(endpoint & "latest.json")
  var latestVersion = parseJson(fetchVersion)["version"].getStr()
  var currentVersion = parseJson(readFile("build_info.json"))["version"].getStr()
  echo("Update endpoint: " & endpoint)
  if parseJson(fetchVersion)["note"].getStr() != "":
    echo("Note from update server: " & parseJson(fetchVersion)["note"].getStr())
  echo("Latest version: " & latestVersion)
  echo("Current version: " & currentVersion)
  var a = parseInt(latestVersion.replace(".", "")) # Remove the dots to compare
  var b = parseInt(currentVersion.replace(".", "")) # Remove the dots to compare
  if (a > b):
    downloadUpdate(endpoint)
  else:
    echo("No new version available.")
    if (a < b):
      echo("You have a newer version than the latest version available on the update endpoint.")
      echo("Do you want to downgrade to version available on update server?")
      write(stdout, "[y/n]: ")
      var input = readLine(stdin)
      if (input == "y"):
        downloadUpdate(endpoint)
      else:
        echo("Downgrading won't be performed.")
         