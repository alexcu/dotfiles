#!/bin/zsh

source $ZSH/oh-my-zsh.sh
source ~/.antigen/antigen.zsh

printf "=======================================================\n"
printf "📡\tUpdating software on $(hostname)...\n"
printf "📡\tStart time $(date)\n"
printf "=======================================================\n\n"

echo "==> Installing App Store packages..."
softwareupdate --install --all

echo "==> Updating Homebrew..."
brew update
brew cleanup
brew cask cleanup

echo "==> Upgrading Homebrew..."
brew upgrade

echo "==> Installing any new packages from ~/.Brewfile..."
brew bundle --global

echo "==> Running Homebrew Doctor..."
brew doctor

echo "==> Running homebrew cask Doctor..."
brew cask doctor

echo "==> Update oh-my-zsh..."
upgrade_oh_my_zsh

echo "==> Update antigen itself..."
antigen selfupdate

echo "==> Update antigen packages..."
antigen update

echo "==> Update atom packages..."
apm update -c false

printf "=======================================================\n"
printf "📡\tSoftware updated on $(hostname)...\n"
printf "📡\tEnd time $(date)\n"
printf "=======================================================\n"
