#!/usr/bin/env bash
echo "Linking ./emacs -> ~/.emacs"
BASEDIR=$(dirname "$0")
ln -s "$BASEDIR/emacs" ~/.emacs
