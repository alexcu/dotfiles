#!/usr/bin/env bash

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "Linking:"
echo "  ./tmux.conf -> $HOME/.tmux.conf"
echo "  ./tmuxp -> $HOME/.tmuxp"
echo "  ./tmuxp.init.sh -> $HOME/.tmux.tmuxp.init"
echo "  ./pane.init.sh -> $HOME/.tmux.pane.init"

ln -nsf "$BASEDIR/tmux.conf" "$HOME/.tmux.conf"
ln -nsf "$BASEDIR/tmuxp" "$HOME/.tmuxp"
ln -nsf "$BASEDIR/tmuxp.init.sh" "$HOME/.tmux.tmuxp.init"
ln -nsf "$BASEDIR/pane.init.sh" "$HOME/.tmux.pane.init"
