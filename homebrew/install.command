#!/bin/sh
echo "Installing Homebrew..."
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "Installed Homebrew!"

echo "Installing Homebrew Bundle..."
brew tap Homebrew/bundle
echo "Installed Homebrew Bundle!"

echo "Linking ./Brewfile -> ~/.Brewfile..."
BASEDIR=$(dirname "$0")
ln -s "$BASEDIR/Brewfile" ~/.Brewfile
echo "Set up ~/.Brewfile!"

echo "Installing [cask] apps from ~/.Brewfile..."
brew bundle --global
echo "Done!"
