#!/usr/bin/env bash
echo "Linking:"
echo "  ./gitignore -> ~/.gitignore"
echo "  ./gitconfig -> ~/.gitconfig"
BASEDIR=$(dirname "$0")
ln -s "$BASEDIR/gitconfig" ~/.gitconfig
ln -s "$BASEDIR/gitignore" ~/.gitignore
