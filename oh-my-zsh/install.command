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
echo "  ./zshrc_antigen.sh -> ~/.zshrc"
echo "  ./zshrc_custom.sh  -> ~/.zshrc_custom"
BASEDIR=$(dirname "$0")
ln -s "$BASEDIR/zshrc_antigen.sh" ~/.zshrc
ln -s "$BASEDIR/zshrc_custom.sh" ~/.zshrc_custom
