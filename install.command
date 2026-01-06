#!/usr/bin/env bash

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

DOTFILES_LINK="$HOME/.dotfiles"
if [ -L "$DOTFILES_LINK" ] || [ ! -e "$DOTFILES_LINK" ]; then
  ln -nsf "$BASEDIR" "$DOTFILES_LINK"
elif [ -d "$DOTFILES_LINK" ]; then
  existing_real="$(cd "$DOTFILES_LINK" && pwd -P)"
  if [ "$existing_real" != "$BASEDIR" ]; then
    echo "WARNING: $DOTFILES_LINK exists and is a directory; expected it to point to $BASEDIR"
  fi
else
  echo "WARNING: $DOTFILES_LINK exists and is not a directory/symlink; skipping link"
fi

try_eval_brew_shellenv() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    return 0
  fi

  local candidate
  for candidate in \
    "/opt/homebrew/bin/brew" \
    "/usr/local/bin/brew" \
    "/home/linuxbrew/.linuxbrew/bin/brew" \
    "$HOME/.linuxbrew/bin/brew"
  do
    if [ -x "$candidate" ]; then
      eval "$("$candidate" shellenv)"
      return 0
    fi
  done

  return 1
}

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
  (cd "$dir" > /dev/null && ./"$script")
}

# If brew exists but isn't on PATH yet, fix it before running anything else.
try_eval_brew_shellenv >/dev/null 2>&1 || true

# Homebrew
install_from_directory "$BASEDIR/brew" "install.command"

# Ensure brew is on PATH for subsequent install scripts (important on Linuxbrew).
if ! try_eval_brew_shellenv >/dev/null 2>&1; then
  echo "ERROR: Homebrew is installed but 'brew' is not on PATH."
  echo "Try: eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
  exit 1
fi

# zsh
install_from_directory "$BASEDIR/zsh" "install.command"

# git
install_from_directory "$BASEDIR/git" "install.command"

# emacs
install_from_directory "$BASEDIR/emacs" "install.command"

# tmux
install_from_directory "$BASEDIR/tmux" "install.command"

echo "All installations completed successfully."
