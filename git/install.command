#!/usr/bin/env bash

set -e

BASEDIR=$(greadlink -f "$(dirname "$0")")

if ! command -v greadlink >/dev/null 2>&1; then
  echo "greadlink is not installed. Please install coreutils to proceed."
  exit 1
fi

BASEDIR=$(greadlink -f "$(dirname "$0")")

echo "Linking:"
echo "  ./gitignore -> $HOME/.gitignore"
echo "  ./gitconfig -> $HOME/.gitconfig"
echo "  ./gcoco -> $HOME/.gcoco"

ln -nsf "$BASEDIR/gitconfig" "$HOME/.gitconfig"
ln -nsf "$BASEDIR/gitignore" "$HOME/.gitignore"
ln -nsf "$BASEDIR/gcoco" "$HOME/.gcoco"
