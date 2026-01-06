#!/usr/bin/env zsh

#
# Personal aliases, functions, and exports
#

# Resolve alias directory from this file's location (works even when sourced via symlink).
_DOTFILES_ALIASES_FILE="${${(%):-%N}:A}"
_DOTFILES_ZSH_DIR="${_DOTFILES_ALIASES_FILE:h}"
_DOTFILES_ALIAS_DIR="${_DOTFILES_ZSH_DIR}/aliases"

# Export dotfiles root for other scripts/aliases (can be overridden by env).
export HOME_DOTFILES="${HOME_DOTFILES:-${_DOTFILES_ZSH_DIR:h}}"

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
source "${_DOTFILES_ALIAS_DIR}/paths.zsh"
source "${_DOTFILES_ALIAS_DIR}/config.zsh"
source "${_DOTFILES_ALIAS_DIR}/utils.zsh"
source "${_DOTFILES_ALIAS_DIR}/colors.zsh"
source "${_DOTFILES_ALIAS_DIR}/time.zsh"
source "${_DOTFILES_ALIAS_DIR}/io.zsh"
source "${_DOTFILES_ALIAS_DIR}/sounds.zsh"
source "${_DOTFILES_ALIAS_DIR}/scripts.zsh"
source "${_DOTFILES_ALIAS_DIR}/tmux.zsh"
source "${_DOTFILES_ALIAS_DIR}/logging.zsh"
source "${_DOTFILES_ALIAS_DIR}/git.zsh"
source "${_DOTFILES_ALIAS_DIR}/git-pr-train.zsh"
source "${_DOTFILES_ALIAS_DIR}/github.zsh"
source "${_DOTFILES_ALIAS_DIR}/projects.zsh"
source "${_DOTFILES_ALIAS_DIR}/python.zsh"
source "${_DOTFILES_ALIAS_DIR}/ports.zsh"
source "${_DOTFILES_ALIAS_DIR}/docker.zsh"
