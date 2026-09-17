#! /usr/bin/env zsh

#
# Tmux aliases
#

# Tmux Init Pane (and clear)
function tip!() { $HOME/.tmux.pane.init "$@" && clear }

# Tmux get Pane IDentifier
alias tpid="tmux display -p '#S:#I.#P'"
