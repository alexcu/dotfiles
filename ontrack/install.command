#!/usr/bin/env bash
echo "Downloading togglCli..."
pip install togglCli

echo "Linking ./ontrack -> /usr/local/bin/ontrack"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/ontrack" /usr/local/bin/ontrack
