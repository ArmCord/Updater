import std/httpclient
import std/json
import std/strutils
import os
var client = newHttpClient()

when isMainModule:
  echo("ArmCord Updater")
  echo("Platform: " & hostOS)
  var fetchVersion = client.getContent("https://armcord.xyz/latest.json")
  var latestVersion = parseJson(fetchVersion)["version"].getStr()
  var currentVersion = parseJson(readFile("build_info.json"))["version"].getStr()
  echo("Latest version: " & latestVersion)
  echo("Current version: " & currentVersion)
  var a = parseInt(latestVersion.replace(".", "")) # Remove the dots to compare
  var b = parseInt(currentVersion.replace(".", "")) # Remove the dots to compare
  if (a > b):
    echo("New version available!")
  else:
    echo("No new version available.")