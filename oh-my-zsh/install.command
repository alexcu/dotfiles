#!/bin/sh
which brew

if [ $? -ne 0 ]; then
  echo "FAILED! Install homebrew first"
  exit 1
fi

echo "Ensuring zsh is installed - ensure homebrew is installed"
brew install zsh

echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Installing antigen..."
git clone https://github.com/zsh-users/antigen.git ~/.antigen

echo "Linking:"
echo "  ./zshrc             -> ~/.zshrc"
echo "  ./zshrc.aliases.zsh -> ~/.zshrc.aliases.zsh"
echo "  ./zshrc.plugins.zsh -> ~/.zshrc.plugins.zsh"
echo "  ./zshrc.custom.zsh  -> ~/.zshrc.custom.zsh"
echo "  ./zshrc.docker.zsh  -> ~/.zshrc.docker.zsh"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/zshrc.zsh" ~/.zshrc
ln -nsf "$BASEDIR/zshrc.plugins.zsh" ~/.zshrc.plugins.zsh
ln -nsf "$BASEDIR/zshrc.aliases.zsh" ~/.zshrc.aliases.zsh
ln -nsf "$BASEDIR/zshrc.custom.zsh" ~/.zshrc.custom.zsh
ln -nsf "$BASEDIR/zshrc.docker.zsh" ~/.zshrc.docker.zsh
ln -nsf "$BASEDIR/p10k.zsh" ~/.p10k.zsh
