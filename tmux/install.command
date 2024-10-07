#!/usr/bin/env bash

set -e

BASEDIR=$(greadlink -f "$(dirname "$0")")

if ! command -v greadlink >/dev/null 2>&1; then
  echo "greadlink is not installed. Please install coreutils to proceed."
  exit 1
fi

BASEDIR=$(greadlink -f "$(dirname "$0")")

echo "Linking:"
echo "  ./tmux.conf -> $HOME/.tmux.conf"
echo "  ./tmuxp -> $HOME/.tmuxp"
echo "  ./tmux.sh -> $HOME/.tmux.sh"

ln -nsf "$BASEDIR/tmux.sh" "$HOME/.tmux.sh"
ln -nsf "$BASEDIR/tmuxp" "$HOME/.tmuxp"
