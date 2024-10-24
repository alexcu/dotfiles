#!/usr/bin/env zsh

#
# Post .zshrc run for things to place "at the end of your .zshrc"
#

# Export .local/bin
export PATH=$PATH:$HOME/.local/bin

# nix daemon
[[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

#
# fzf-git.sh bindings
#

# Ensure any default git completions are loaded first
source $HOMEBREW_PREFIX/share/zsh/functions/_git
source $ZSH_CUSTOM/plugins/fzf-git/fzf-git.sh
