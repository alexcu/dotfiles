#!/usr/bin/env zsh

#
# Customised commands (evals, setopts etc.) to run
#

# Initialise rbenv + pyenv + jenv
if [ -x "$(command -v rbenv)" ]; then eval "$(rbenv init -)"; fi
if [ -x "$(command -v pyenv)" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi
if [ -x "$(command -v jenv)"  ]; then eval "$(jenv init -)"; fi

# Additional Zsh (+emacs) Keybindings
# https://zsh.sourceforge.io/Guide/zshguide04.html
bindkey "^w" kill-region

# Remove right-hand side prompts from p10k (for copying)
function toggle-right-prompt() { p10k display '*/right'=hide,show; }
zle -N toggle-right-prompt
bindkey '^P' toggle-right-prompt

# Individual tab histories
setopt noappendhistory
setopt no_share_history
unsetopt inc_append_history
unsetopt share_history

# Drag and drop commands to execute
# https://discussions.apple.com/thread/254451946
unset zle_bracketed_paste

# Disable "You've got mail" prompt
unset MAILCHECK

# Homebrew updates every week
HOMEBREW_AUTO_UPDATE_SECS="604800"

# Completion waiting dots causing havoc with multiline themes
# https://github.com/ohmyzsh/ohmyzsh/issues/6226#issuecomment-321682739
COMPLETION_WAITING_DOTS="false"

# History management
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt INC_APPEND_HISTORY_TIME
