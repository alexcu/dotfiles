#!/usr/bin/env zsh

#
# Pre .zshrc run for things to place "at the top of your .zshrc"
#

# Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Disable auto-setting terminal title for tmuxp
export DISABLE_AUTO_TITLE='true'

# Set the custom directory of zsh plugins
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Set caching directory
export ZSH_COMDUMP="$HOME/.cache/zsh/compcache/zcomdump"
