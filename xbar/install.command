#!/bin/sh
echo "Linking:"
echo "  ./plugins -> ~/Library/Application\ Support/xbar/plugins"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/plugins" ~/Library/Application\ Support/xbar/plugins
