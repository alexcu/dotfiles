#!/usr/bin/env zsh

# Always use emacs
export EDITOR='emacs'
export VISUAL='emacs'

# Initialise rbenv + pyenv + jenv
if [ -x "$(command -v rbenv)" ]; then eval "$(rbenv init -)"; fi
if [ -x "$(command -v pyenv)" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi
if [ -x "$(command -v jenv)"  ]; then eval "$(jenv init -)"; fi

# Prefer /usr/local/bin over /usr/bin for brew installs
export PATH="$HOME/.pyenv/bin:$PATH"

# Additional Zsh (+emacs) Keybindings
# https://zsh.sourceforge.io/Guide/zshguide04.html
bindkey "^w" kill-region
function toggle-right-prompt() { p10k display '*/right'=hide,show; }
zle -N toggle-right-prompt
bindkey '^P' toggle-right-prompt

# Don't auto-update Brew, instead use brewautoupate
# See https://apple.stackexchange.com/a/353010
export HOMEBREW_NO_AUTO_UPDATE=1

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

# Disable auto-setting terminal title
DISABLE_AUTO_TITLE="true"

# Completion waiting dots causing havoc with multiline themes
# https://github.com/ohmyzsh/ohmyzsh/issues/6226#issuecomment-321682739
COMPLETION_WAITING_DOTS="false"

# Architecture Changes
alias m1='arch -arm64'
alias intel='arch -x86_64'

# Homebrew on M1 - iBrew for Rosetta Brew
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
alias ibrew='arch -x86_64 /usr/local/bin/brew'

# Colorize
ZSH_COLORIZE_STYLE="xcode"
export CLICOLOR=1
alias l='ls -lahG'
alias cat='ccat'
