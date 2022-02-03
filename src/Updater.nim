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
    echo("New version available!")
    echo("Getting the latest asar.")
    try:
      writeFile("app.asar", fetch(endpoint & "app.asar"))
      writeFile("build_info.json", fetch(endpoint & "latest.json"))
    except Exception as e:
      echo("Failed to download the latest asar: ", e.msg)
      quit(1)
    echo("Update installation has finished. You should be able to use the new version of ArmCord.")
  else:
    echo("No new version available.")
    if (a < b):
      echo("You have a newer version than the latest version available on the update endpoint.")
      echo("Do you want to downgrade to version available on update server?")
      write(stdout, "[y/n]: ")
      var input = readLine(stdin)
      if (input == "y"):
        echo("Getting the latest asar.")
        try:
          writeFile("app.asar", fetch(endpoint & "app.asar"))
          writeFile("build_info.json", fetch(endpoint & "latest.json"))
        except Exception as e:
          echo("Failed to download the latest asar: ", e.msg)
          quit(1)
        echo("Update installation has finished. You should be able to use the new version of ArmCord.")
      else:
        echo("Downgrading won't be performed.")