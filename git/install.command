#!/usr/bin/env bash
echo "Linking:"
echo "  ./gitignore -> ~/.gitignore"
echo "  ./gitconfig -> ~/.gitconfig"
echo "  ./gcoco -> ~/.gcoco"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/gitconfig" ~/.gitconfig
ln -nsf "$BASEDIR/gitignore" ~/.gitignore
ln -nsf "$BASEDIR/gcoco" ~/.gcoco
