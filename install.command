#!/usr/bin/env bash

set -e

# Function to install software from a directory
install_from_directory() {
  local dir="$1"
  local script="$2"

  if [ ! -d "$dir" ]; then
    echo "Directory $dir does not exist."
    exit 1
  fi

  if [ ! -f "$dir/$script" ]; then
    echo "Install script $dir/$script does not exist."
    exit 1
  fi

  echo "Installing from $dir..."
  pushd "$dir" > /dev/null
  ./"$script"
  popd > /dev/null
}

# Homebrew
install_from_directory "./brew" "install.command"

# zsh
install_from_directory "./zsh" "install.command"

# git
install_from_directory "./git" "install.command"

# emacs
install_from_directory "./emacs" "install.command"

# tmux
install_from_directory "./tmux" "install.command"

echo "All installations completed successfully."
