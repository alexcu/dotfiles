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
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000  # Number of history entries to keep in memory
SAVEHIST=1000000  # Number of history entries to save to the file

# History options
setopt HIST_EXPIRE_DUPS_FIRST   # Remove older duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS         # Don't record an entry that was just executed
setopt HIST_REDUCE_BLANKS       # Remove leading/trailing blanks and reduce multiple spaces
setopt INC_APPEND_HISTORY       # Write each command to the history file immediately after execution
setopt INC_APPEND_HISTORY_TIME  # Record timestamps for each history entry

# Ensure per-session history management
unsetopt share_history

# Ignore any history with a space prefix
setopt HIST_IGNORE_SPACE

# Always use emacs
export EDITOR='emacs'
export VISUAL='emacs'

# Prefer /usr/local/bin over /usr/bin for brew installs
export PATH="$HOME/.pyenv/bin:$PATH"

# Don't auto-update Brew, instead use brewautoupate
# See https://apple.stackexchange.com/a/353010
export HOMEBREW_NO_AUTO_UPDATE=1

# Colorize shell
ZSH_COLORIZE_STYLE="xcode"
export CLICOLOR=1
export BAT_THEME="Visual Studio Dark+"

# Rebind SIGQUIT from ^\ to ^X for tmux ^\\
if [[ -t 1 ]]; then
    stty quit ^X
    stty quit ^-
fi
