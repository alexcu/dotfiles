#!/usr/bin/env zsh

#
# Personal aliases, functions, and exports
#

# SETUP: Undefines pre-existing aliases or functions for redefinition of work-related stuff
function undef() {
  local original_name="$1"
  local new_name="_$1"

  if typeset -f "$original_name" >/dev/null; then
    eval "$(typeset -f "$original_name" | sed "s/^$original_name/$new_name/")"
  elif alias "$original_name" >/dev/null 2>&1; then
    local alias_definition=$(alias "$original_name" | sed "s/^alias $original_name=//")
    eval "alias $new_name=$alias_definition"
    unalias "$original_name"
  fi
}

# Alias imports (order is important!)
source $HOME/.dotfiles/zsh/aliases/paths.zsh
source $HOME/.dotfiles/zsh/aliases/config.zsh
source $HOME/.dotfiles/zsh/aliases/utils.zsh
source $HOME/.dotfiles/zsh/aliases/colors.zsh
source $HOME/.dotfiles/zsh/aliases/time.zsh
source $HOME/.dotfiles/zsh/aliases/io.zsh
source $HOME/.dotfiles/zsh/aliases/sounds.zsh
source $HOME/.dotfiles/zsh/aliases/scripts.zsh
source $HOME/.dotfiles/zsh/aliases/tmux.zsh
source $HOME/.dotfiles/zsh/aliases/logging.zsh
source $HOME/.dotfiles/zsh/aliases/git.zsh
source $HOME/.dotfiles/zsh/aliases/git-pr-train.zsh
source $HOME/.dotfiles/zsh/aliases/github.zsh
source $HOME/.dotfiles/zsh/aliases/projects.zsh
source $HOME/.dotfiles/zsh/aliases/python.zsh
source $HOME/.dotfiles/zsh/aliases/ports.zsh
source $HOME/.dotfiles/zsh/aliases/docker.zsh
