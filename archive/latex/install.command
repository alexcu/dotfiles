#!/bin/sh
echo "Linking:"
echo "  ./latex -> ~/.latex"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR" ~/.latex
