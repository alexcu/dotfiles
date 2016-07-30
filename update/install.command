#!/bin/sh
echo "Linking ./update.command to /usr/local/bin/update..."
BASEDIR=$(dirname "$0")
echo $BASEDIR
ln -nsf "$BASEDIR/update.command" /usr/local/bin/update
