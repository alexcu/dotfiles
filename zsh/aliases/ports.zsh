#! /usr/bin/env zsh

#
# Ports aliases
#

# What port is open
function whatport() { lsof -ti :$1 }

# Kill port
function killport() { lsof -ti :$1 | xargs kill }

# Wait for port to open, then run command
function waitport() {
  [[ "$#" -lt 1 ]] && { echo "Usage: waitport [port] [-- [cmd]]"; return 1; }

  local port="$1"
  shift

  if [[ "$1" == "--" ]]; then
    shift
  fi

  echo -n "Waiting for port $port to be opened..."

  while [[ -z $(whatport "$port") ]]; do
    sleep 1
  done

  echo " success! (pid=$(whatport "$port"))"

  if [[ "$#" -gt 0 ]]; then
    "$@"
  fi
}
