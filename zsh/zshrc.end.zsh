#!/usr/bin/env zsh

#
# Post .zshrc run for things to place "at the end of your .zshrc"
#

# Post-load sourcing for brew-installed plugins...
brewplugins="$(brew --prefix)/share/"

export PATH=$PATH:/Users/alexcu/.local/bin

# Powerlevel10k Theme
# https://github.com/romkatv/powerlevel10k
source "$brewplugins/powerlevel10k/powerlevel10k.zsh-theme"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Zsh Autocomplete
# https://github.com/marlonrichert/zsh-autocomplete
source "$HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# Zsh Autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
source "$brewplugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Zsh Syntax Highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting
source "$brewplugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# nix daemon
[[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
