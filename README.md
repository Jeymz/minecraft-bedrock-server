# Minecraft Bedrock Server Docker Contrainer

A lightweight and simple container solution to host a minecraft betrock server locally.

## Quick Start
  ```bash
  docker pull robotti/minecraft-bedrock:latest
  docker run robotti/minecraft-bedrock:latest
  ```

## Advanced Usage
### Pull container image
```bash
docker pull robotti/minecraft-bedrock:latest
```

### Persist `world` & `config`
```bash
docker run robotti/minecraft-bedrock:latest --name $CONTAINERNAME -p 19132:19132/udp -v $(pwd)/lib/worlds:/home/miner/lib/worlds -v $(pwd)/config:/home/miner/config
```
  - **NOTE**: You may need to run the following commands to create the directory first
    ```bash
    mkdir config
    mkdir lib
    mkdir lib/worlds
    ```

### Persist `lib` & `config`
  ```bash
  docker run robotti/minecraft-bedrock:latest --name $CONTAINERNAME -p 19132:19132/udp -v $(pwd)/lib:/home/miner/lib -v $(pwd)/config:/home/miner/config
  ```
  - **NOTE**: You may need to run the following commands to create the directory first
    ```bash
    mkdir config
    mkdir lib
    ```

### Build it yourself
```bash
docker build -t $CONTAINERNAME .
docker run --name $CONTAINERNAME -p 19132:19132/udp 
```

### Arguments / Environment Variables
- PORT
  - Specifies the port to expose
  - If none is provided defaults to `19132`

## Additional details
### Container Directory Structure

- Before run
  ```bash
  /
  └── home
      └── miner
          ├── config # User Supplied or empty
          │   ├── allowlist.json
          │   ├── permissions.json
          │   └── server.properties
          ├── lib
          │   └── worlds # User supplied or empty
          │       └── $WORLDNAME
          │           └── $World_Files
          └── setup.sh
  ```

- After run
  ```bash
  /
  └── home
      └── miner
          ├── config # User Supplied or empty
          │   ├── allowlist.json
          │   ├── permissions.json
          │   └── server.properties
          ├── lib
          │   ├── allowlist.json # If not supplied in config default
          │   ├── data # Temporary directory used for version updates if persisting entire lib folder
          │   ├── $Minecraft_Bedrock_Server_Files
          │   ├── $Minecraft_Bedrock_Server_Folders
          │   ├── permissions.json # If not supplied in config default
          │   ├── server.properties # If not supplied in config default
          │   ├── worlds # User supplied or empty
          │   │   └── $WORLDNAME
          │   │       └── $World_Files
          │   └── version.txt # Used to identify current version if persisting entire lib folder
          ├── setup.sh
          └── versions.txt # List of all stable versions used to determine latest version
  ```

### Persistance Strategies
**Note**: Prior to starting the server every run the contents of the `config` directory are copied to the `lib` directory to allow for customizations & static versioning
1. Configuration Persistence
    - This strategy will persist the least amount of data and allow for state preservation
    - This strategy persists both the `config` and `$WORLDNAME` directories only
    - This strategy will require the following 2 mounts
      - `./local-dir/config` > `/home/miner/config`
      - `./local-dir/$WORLDNAME` > `/home/miner/lib/worlds/$WORLDNAME`
2. Complete Persistence
    - This strategy will persist almost all the data
    - This strategy would persist the `lib` and `config` directory
    - This strategy will require the following 2 mounts
      - `./local-dir/lib` > `/home/miner/lib`
      - `./local-dir/lib` > `/home/miner/config` 

### Container Runtime Steps
The following steps are performed on every run
1. A complete list of stable versions is fetched from `https://minecraft.fandom.com/wiki/Bedrock_Dedicated_Server` and stored in `/home/miner/version.txt`
2. The latest version is identified and then compared to the `/home/miner/lib/version.txt` version.
    - If the version installed is the same **Step 3** & **Step 4** are skipped
    - If the version installed is older the latest version **Step 3** & **Step 4** are performed
    - If there is no version installed **Step 3** & **Step 4** are performed
3. The latest version is downloaded from `https://minecraft.azureedge.net/bin-linux/` and extracted to the `/home/miner/lib/data` directory
    - The version downloaded is stored in `/home/miner/lib/version.txt`
4. The contents of `/home/miner/lib/data` are moved to `/home/miner/lib`
    - All files & folders in `/home/miner/lib` will be overwritten with the files & folders from `/home/miner/lib/data`
5. The contents of `/home/miner/config` are moved to `/home/miner/lib`
    - All files and folders in `/home/miner/lib` will be overwritten with the files & folders from `/home/miner/config`
    - If you want to persist a single version of the Minecraft Bedrock Server all files will need to be persisted in the `/home/miner/config` config directory
6. The `/home/miner/lib/bedrock_server` is started