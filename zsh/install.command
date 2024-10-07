#!/usr/bin/env bash

set -e

# Must install homebrew first...
if [ -z "$(which brew)" ]; then
  echo "Run .dotfiles/brew/install.command first..."
  exit 1
fi

# Checking for zsh...
echo "Checking for zsh..."
if which zsh >/dev/null 2>&1; then
  echo "zsh is installed"
else
  echo "zsh is not installed. Installing it via brew..."
  brew install zsh
fi

# Checking for oh-my-zsh...
echo "Checking for oh-my-zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "oh-my-zsh is installed"
else
  echo "oh-my-zsh is not installed. Installing it..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# Link it up
echo "Linking .zshrc files..."
BASEDIR=$(greadlink -f "$(dirname "$0")")
echo "  ./zshrc                 -> $HOME/.zshrc"
echo "  ./zshrc.end.zsh -> $HOME/.zshrc.top.zsh"
echo "  ./zshrc.top.zsh -> $HOME/.zshrc.end.zsh"
echo "  ./zshrc.aliases.zsh     -> $HOME/.zshrc.aliases.zsh"
echo "  ./zshrc.plugins.zsh     -> $HOME/.zshrc.plugins.zsh"
echo "  ./zshrc.custom.zsh      -> $HOME/.zshrc.custom.zsh"
echo "  ./zshrc.docker.zsh      -> $HOME/.zshrc.docker.zsh"
ln -nsf "$BASEDIR/zshrc.zsh" "$HOME/.zshrc"
ln -nsf "$BASEDIR/zshrc.top.zsh" "$HOME/.zshrc.top.zsh"
ln -nsf "$BASEDIR/zshrc.end.zsh" "$HOME/.zshrc.end.zsh"
ln -nsf "$BASEDIR/zshrc.plugins.zsh" "$HOME/.zshrc.plugins.zsh"
ln -nsf "$BASEDIR/zshrc.aliases.zsh" "$HOME/.zshrc.aliases.zsh"
ln -nsf "$BASEDIR/zshrc.custom.zsh" "$HOME/.zshrc.custom.zsh"
ln -nsf "$BASEDIR/zshrc.docker.zsh" "$HOME/.zshrc.docker.zsh"
ln -nsf "$BASEDIR/p10k.zsh" "$HOME/.p10k.zsh"

# Lock down .zshrc for other scripts to butcher
echo "Locking down .zshrc from future edits..."
chmod 600 "$HOME/.zshrc"
sudo chflags uchg "$HOME/.zshrc"
