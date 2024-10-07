#!/usr/bin/env bash

set -e

# Check if greadlink is installed
if ! command -v greadlink >/dev/null 2>&1; then
  echo "greadlink is not installed. Please install coreutils to proceed."
  exit 1
fi

# Ensure the script is being run as root if modifying /usr/local/bin
if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to be run as root to modify /usr/local/bin."
  exit 1
fi

# Display setup instructions
echo
echo "!!! Place a generic access token in ~/.bitlytoken !!!"
echo "!!! See: https://bitly.is/2Kpcq4e !!!"
echo

# Determine the directory where the script is located
BASEDIR=$(greadlink -f "$(dirname "$0")")

# Check if the bitly file exists
if [ ! -f "$BASEDIR/bitly" ]; then
  echo "The file './bitly' does not exist in the script's directory."
  exit 1
fi

# Link the bitly executable to /usr/local/bin
echo "Linking ./bitly -> /usr/local/bin/bitly"
ln -nsf "$BASEDIR/bitly" /usr/local/bin/bitly

echo "Symbolic link created successfully."
