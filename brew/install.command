#!/bin/bash

set -e

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installed!"
else
  echo "Homebrew is already installed."
fi

# Check if coreutils is installed
if ! brew list coreutils >/dev/null 2>&1; then
  echo "Installing coreutils..."
  brew install coreutils
  echo "coreutils installed!"
else
  echo "coreutils is already installed."
fi

# Check if Homebrew Bundle is tapped
if ! brew tap-info | grep -q 'homebrew/bundle'; then
  echo "Installing Homebrew Bundle..."
  brew tap Homebrew/bundle
  echo "Homebrew Bundle installed!"
else
  echo "Homebrew Bundle is already tapped."
fi

# Check if greadlink is installed
if command -v greadlink >/dev/null 2>&1; then
  echo "Linking ./Brewfile -> ~/.Brewfile..."
  BASEDIR=$(greadlink -f "$(dirname "$0")")
  ln -nsf "$BASEDIR/Brewfile" ~/.Brewfile
  echo "Set up ~/.Brewfile!"
else
  echo "greadlink is not installed. Please install coreutils to proceed."
  exit 1
fi

# Install apps from Brewfile
echo "Installing [cask] apps from ~/.Brewfile..."
brew bundle --global
echo "Done!"
