#!/usr/bin/env bash
echo "Linking:"
echo "  ./gitignore -> ~/.gitignore"
echo "  ./gitconfig -> ~/.gitconfig"
BASEDIR=$(dirname "$0")
ln -nsf "$BASEDIR/gitconfig" ~/.gitconfig
ln -nsf "$BASEDIR/gitignore" ~/.gitignore
