#!/usr/bin/env bash

set -e

¢

if ! command -v greadlink >/dev/null 2>&1; then
  echo "greadlink is not installed. Please install coreutils to proceed."
  exit 1
fi

BASEDIR=$(greadlink -f "$(dirname "$0")")

echo "Linking:"
echo "  ./tmux.conf -> $HOME/.tmux.conf"
echo "  ./tmuxp -> $HOME/.tmuxp"
echo "  ./tmuxp.init.sh -> $HOME/.tmux.tmuxp.init"
echo "  ./pane.init.sh -> $HOME/.tmux.pane.init"

ln -nsf "$BASEDIR/tmux.conf" "$HOME/.tmux.conf"
ln -nsf "$BASEDIR/tmuxp" "$HOME/.tmuxp"
ln -nsf "$BASEDIR/tmuxp.init.sh" "$HOME/.tmux.tmuxp.init"
ln -nsf "$BASEDIR/pane.init.sh" "$HOME/.tmux.pane.init"
