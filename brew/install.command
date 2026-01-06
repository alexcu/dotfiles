#!/usr/bin/env bash

set -e

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

# Check if Homebrew is installed
if ! try_eval_brew_shellenv >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installed!"
fi

if ! try_eval_brew_shellenv >/dev/null 2>&1; then
  echo "ERROR: Homebrew is installed but 'brew' is not on PATH."
  echo "Try: eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
  exit 1
fi

# Check if coreutils is installed
if ! brew list coreutils >/dev/null 2>&1; then
  echo "Installing coreutils..."
  brew install coreutils
  echo "coreutils installed!"
else
  echo "coreutils is already installed."
fi

echo "Linking ./Brewfile -> ~/.Brewfile..."
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -nsf "$BASEDIR/Brewfile" "$HOME/.Brewfile"
echo "Set up ~/.Brewfile!"

# Install apps from Brewfile
echo "Installing [cask] apps from ~/.Brewfile..."
brew bundle --global
echo "Done!"
