#!/bin/sh
echo "Linking ./update.command to /usr/local/bin/update..."
BASEDIR=$(dirname "$0")
ln -s "$BASEDIR/update.command" /usr/local/bin/update
