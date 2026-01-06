#!/usr/bin/env bash

set -e

# Must install homebrew first...
if ! command -v brew >/dev/null 2>&1; then
  echo "Run .dotfiles/brew/install.command first..."
  exit 1
fi

# Checking for zsh...
echo "Checking for zsh..."
if command -v zsh >/dev/null 2>&1; then
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

echo "Checking for fzf-tab zsh plugin..."
if [ -d "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" ]; then
  echo "fzf-tab is installed"
else
  echo "fzf-tab is not installed. Installing it..."
  git clone https://github.com/Aloxaf/fzf-tab.git "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"
  if [ "$(uname)" = "Linux" ] && command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y zsh-dev
  fi
  # Required for building binary tab module
  brew install groff
fi

echo "Checking for fzf-git zsh plugin..."
if [ -d "$HOME/.oh-my-zsh/custom/plugins/fzf-git" ]; then
  echo "fzf-git is installed"
else
  echo "fzf-git is not installed. Installing it..."
  git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/.oh-my-zsh/custom/plugins/fzf-git"
fi

# Make projects and llog directories
echo "Making /usr/local/llog -> ~/.llog and /usr/local/projects -> ~/.proj"
sudo mkdir -p /usr/local/llog
sudo chown "$USER" /usr/local/llog
sudo mkdir -p /usr/local/projects
sudo chown "$USER" /usr/local/projects
if [ -e "$HOME/.llog" ] && [ ! -L "$HOME/.llog" ]; then
  echo "WARNING: $HOME/.llog exists and is not a symlink; skipping link"
else
  ln -nsf /usr/local/llog "$HOME/.llog"
fi
if [ -e "$HOME/.proj" ] && [ ! -L "$HOME/.proj" ]; then
  echo "WARNING: $HOME/.proj exists and is not a symlink; skipping link"
else
  ln -nsf /usr/local/projects "$HOME/.proj"
fi

# Link it up
echo "Linking .zshrc files..."
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
echo "  ./zshrc                 -> $HOME/.zshrc"
echo "  ./zshrc.top.zsh         -> $HOME/.zshrc.top.zsh"
echo "  ./zshrc.end.zsh         -> $HOME/.zshrc.end.zsh"
echo "  ./zshrc.aliases.zsh     -> $HOME/.zshrc.aliases.zsh"
echo "  ./zshrc.plugins.zsh     -> $HOME/.zshrc.plugins.zsh"
echo "  ./zshrc.custom.zsh      -> $HOME/.zshrc.custom.zsh"
echo "  ./zshrc.docker.zsh      -> $HOME/.zshrc.docker.zsh"
echo "  ./p10k.zsh              -> $HOME/.p10k.zsh"
echo "  ./fzf-preview.zsh       -> $HOME/.zshrc.plugins.fzf-preview.zsh"

ln -nsf "$BASEDIR/zshrc.zsh" "$HOME/.zshrc"
ln -nsf "$BASEDIR/zshrc.top.zsh" "$HOME/.zshrc.top.zsh"
ln -nsf "$BASEDIR/zshrc.end.zsh" "$HOME/.zshrc.end.zsh"
ln -nsf "$BASEDIR/zshrc.plugins.zsh" "$HOME/.zshrc.plugins.zsh"
ln -nsf "$BASEDIR/zshrc.aliases.zsh" "$HOME/.zshrc.aliases.zsh"
ln -nsf "$BASEDIR/zshrc.custom.zsh" "$HOME/.zshrc.custom.zsh"
ln -nsf "$BASEDIR/zshrc.docker.zsh" "$HOME/.zshrc.docker.zsh"
ln -nsf "$BASEDIR/p10k.zsh" "$HOME/.p10k.zsh"
ln -nsf "$BASEDIR/fzf-preview.zsh" "$HOME/.zshrc.plugins.fzf-preview.zsh"

# Lock down .zshrc for other scripts to butcher
echo "Locking down .zshrc from future edits..."
chmod 600 "$HOME/.zshrc"
if [ "$(uname)" = "Darwin" ]; then
  sudo chflags uchg "$HOME/.zshrc"
fi

# Need to build fzf-tab binary
echo "Please restart shell and build fzf-tab binary by running:"
if [ "$(uname)" = "Linux" ]; then
    echo "    sudo apt install libncurses5-dev libncursesw5-dev"
fi
echo "    build-fzf-tab-module"

echo "Setting Zsh as default shell..."
ZSH_PATH="$(command -v zsh)"
if [ -f /etc/shells ] && ! grep -qx "$ZSH_PATH" /etc/shells; then
  echo "Adding $ZSH_PATH to /etc/shells..."
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi
chsh -s "$ZSH_PATH"
