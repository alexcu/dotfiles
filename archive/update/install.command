#!/bin/sh
echo "Linking ./update.command to /usr/local/bin/update..."
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/update.command" /usr/local/bin/update
