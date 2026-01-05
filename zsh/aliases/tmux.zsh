#! /usr/bin/env zsh

#
# Tmux aliases
#

# Tmux Init Pane
alias tip="$HOME/.tmux.pane.init"

# Tmux Init Pane (and clear)
function tip!() { tip "$@" && clear }

# Tmux get Pane IDentifier
alias tpid="tmux display -p '#S:#I.#P'"
