#!/usr/bin/env bash
echo
echo "!!! Place a generic access token in ~/.bitlytoken !!!"
echo "!!! See: https://bitly.is/2Kpcq4e !!!"
echo
echo "Linking ./bitly -> /usr/local/bin/bitly"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/bitly" /usr/local/bin/bitly
