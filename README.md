# Updater
Experimental updater for ArmCord made in Nim.
## Features

- **Quick and lightweight** 
- **One binary is whole updater**
- **Supports custom update servers**
- **Checks for checksums**
## How to use it?
### 1. Client side:
- Download the latest version of the updater from [here](https://github.com/ArmCord/Updater/releases/latest).
- Put it in resources folder of ArmCord installation:    
 **Windows**: `%localappdata%\Programs\ArmCord\resources\`   
 **Linux (aur)**: `/opt/armcord/resources/`   
 - Check if you have `build_info.json` file in the folder. If not, create it and fill it with valid information like seen [here](https://github.com/ArmCord/Updater/blob/main/examples/example_build_info.json).
 - Enjoy the updater ;)     
### 2. Server side:
- ArmCord Updater uses statically deployed update files. This means you can use it on platforms like Github Pages or Vercel. To start you need to have two files:    

**latest.json**: This file contains information about the current version of the application that's available on update server. It is used by the updater to determine if the update is needed. It is exact to [`build_info.json`](https://github.com/ArmCord/Updater/blob/main/examples/example_build_info.json)
    
**app.asar**: This file contains the app itself. It is used by the updater to apply the update. It contains the whole app source code compiled (Typescript ---> Javascript) and minified.
- Place the files in the folder you want to deploy which can be root directory. This becomes your new `update_endpoint` value for the `latest.json`**/**`build_info.json`