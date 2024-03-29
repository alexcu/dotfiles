#!/bin/sh
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Installed Homebrew!"

# Need coreutils to use greadlink
echo "Installing brew coreutils..."
brew install coreutils

echo "Installing Homebrew Bundle..."
brew tap Homebrew/bundle
echo "Installed Homebrew Bundle!"

echo "Linking ./Brewfile -> ~/.Brewfile..."
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/Brewfile" ~/.Brewfile
echo "Set up ~/.Brewfile!"

echo "Installing [cask] apps from ~/.Brewfile..."
brew bundle --global
echo "Done!"
