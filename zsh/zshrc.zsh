#!/usr/bin/env zsh

#
# READ ONLY INSTRUCTIONS:
#
# Prevent other scripts from auto-editing my .zshrc
#
#   chmod 600 ~/.zshrc
#   sudo chflags uchg ~/.zshrc
#
# To unlock for edits, run the alias:
#
#   cfg_zsh
#
# or:
#
#   sudo chflags nouchg ~/.zshrc
#

# Pre-run for exeucting at top of .zshrc
source $HOME/.zshrc.top.zsh

# Load zsh plugins
source $HOME/.zshrc.plugins.zsh

# Source the plugins
export ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Custom zsh for personal tidbits
source $HOME/.zshrc.aliases.zsh
source $HOME/.zshrc.custom.zsh
source $HOME/.zshrc.docker.zsh

# Custom zsh for work tidbits if exists
if [ -x $HOME_WORK_DOTFILES ]; then
  source $HOME_WORK_DOTFILES
fi

# Post-run for executing at end of .zshrc
source $HOME/.zshrc.end.zsh

