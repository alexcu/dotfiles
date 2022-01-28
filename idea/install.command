#!/usr/bin/env bash
echo "Linking:"
echo "  ./idea -> /usr/local/bin/idea"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/idea" /usr/local/bin/idea
