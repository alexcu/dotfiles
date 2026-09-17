#! /usr/bin/env zsh

#
# Sounds aliases
#

function oops() {
  local sounds=("$HOME"/Library/Sounds/oops_*.m4a)
  afplay -v 0.3 "${sounds[$((RANDOM % ${#sounds[@]} + 1))]}"
}

# Ping alert sounds
alias sosumi="afplay -v 0.5 $HOME/Library/Sounds/Sosumi.aiff"
alias quack="afplay -v 0.3 $HOME/Library/Sounds/Quack.aiff"
alias indigo="afplay -v 0.3 $HOME/Library/Sounds/Indigo.aiff"
alias basso="afplay -v 0.3 $HOME/Library/Sounds/Basso.aiff"
alias ohno="afplay -v 0.3 $HOME/Library/Sounds/ohno.m4a"
alias keepquacking="while true; do quack; sleep 1; done"
alias beep="quack||oops"
alias p="beep"
