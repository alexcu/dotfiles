#!/usr/bin/env zsh

#
# Pre .zshrc run for things to place "at the top of your .zshrc"
#

# Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Ensure Homebrew env vars exist (HOMEBREW_PREFIX, PATH, etc).
# This avoids sourcing paths like `/share/...` when HOMEBREW_PREFIX is unset (common on Linuxbrew).
if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  else
    for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
      if [[ -x "$_brew" ]]; then
        eval "$("$_brew" shellenv)"
        break
      fi
    done
    unset _brew
  fi
fi

# Disable auto-setting terminal title for tmuxp
export DISABLE_AUTO_TITLE='true'

# Set the custom directory of zsh plugins
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Set caching directory
export ZSH_COMDUMP="$HOME/.cache/zsh/compcache/zcomdump"
