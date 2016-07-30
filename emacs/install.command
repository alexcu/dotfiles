#!/usr/bin/env bash
echo "Linking ./emacs -> ~/.emacs"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/emacs" ~/.emacs
