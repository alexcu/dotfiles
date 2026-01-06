#!/usr/bin/env bash

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "Linking:"
echo "  ./gitignore -> $HOME/.gitignore"
echo "  ./gitconfig -> $HOME/.gitconfig"
echo "  ./gcoco -> $HOME/.gcoco"

ln -nsf "$BASEDIR/gitconfig" "$HOME/.gitconfig"
ln -nsf "$BASEDIR/gitignore" "$HOME/.gitignore"
ln -nsf "$BASEDIR/gcoco" "$HOME/.gcoco"
