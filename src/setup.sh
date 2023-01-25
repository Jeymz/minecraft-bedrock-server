#!/bin/bash

# Fetch the fandom webpage that contains the various versions available
curl https://minecraft.fandom.com/wiki/Bedrock_Dedicated_Server | \
# Find all the relevant links to linux versions available on the page
grep -o 'href="https://minecraft.azureedge.net/bin-linux/bedrock-server-.*.zip"' | \
# Store the versions only into a version.txt file
sed 's/.*server-\(.*\).zip.*/\1/' > versions.txt

# Get the latest version from the file
version=$(tail -n 1 versions.txt)
echo "Latest version: $version"

# Check is there is a lib directory, and a version file.
if [ -d lib ] && [ -f lib/version.txt ]; then
  # Get the version from the lib/version.txt file
  lib_version=$(tail -n 1 lib/version.txt)
  echo "Current version: $lib_version"
  # If the latest version does not meet the current version
  if [ "$version" != "$lib_version" ]; then
    echo "Updating to version: $version"
    # If a data directory exists already
    if [ -d lib/data ]; then
      rm -Rf lib/data
    fi
    curl -o "latest.zip" "https://minecraft.azureedge.net/bin-linux/bedrock-server-$version.zip"
    unzip "latest.zip" -d lib/data
    mv -f lib/data/* lib/
    echo $version > lib/version.txt
  fi
else
  if [ ! -d lib ]; then
    mkdir lib
  fi
  if [ -d lib/data ]; then
    rm -Rf lib/data
  fi
  curl -o "latest.zip" "https://minecraft.azureedge.net/bin-linux/bedrock-server-$version.zip"
  unzip "latest.zip" -d lib/data
  mv -f lib/data/* lib/
  echo $version > lib/version.txt
fi

# Cleanup
if [ -f latest.zip ]; then
  rm latest.zip
fi
if [ -f versions.txt ]; then
  rm versions.txt
fi

if [ -d config ]; then
  cp config/* lib/
fi
export LD_LIBRARY_PATH=./
cd lib
./bedrock_server
exit 0