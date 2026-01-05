#! /usr/bin/env zsh

#
# Path aliases
#

# Common HOME paths
export HOME_DESKTOP="$HOME/Desktop"
export HOME_DOTFILES="$HOME/.dotfiles"
export HOME_WORK_DOTFILES="$HOME/.zshrc.work.zsh"
export HOME_DOWNLOADS="$HOME/Downloads"
export HOME_REPOS="$HOME/repos"
export HOME_GIT_WORKTREES="$HOME_REPOS/worktrees"
export HOME_WORK="$HOME/work"
export HOME_PROJECTS="$HOME/.proj"
export HOME_LLOG="$HOME/.llog"
export HOME_SCRIPTS="$HOME/.scripts"

# Common HOME paths (short)
export d="$HOME_DESKTOP"
export l="$HOME_DOWNLOADS"

# Tilde suffixes
alias \~d="$HOME_DESKTOP"
alias \~l="$HOME_DOWNLOADS"
alias \~r="$HOME_REPOS"
alias \~w="$HOME_WORK"
alias \~s="$HOME_SCRIPTS"
alias \~p="$HOME_PROJECTS"
alias \~llog="$HOME_LLOG"

# cd Up (up one directory)
alias cdu="cd .."

# cd Back (previous) directory
alias cdb="cd -"

# cd to Desktop directory
alias cdd="cd $HOME_DESKTOP"

# cd to DownLoads directory
alias cdl="cd $HOME_DOWNLOADS"

# cd to Repos directory
alias cdr="cd $HOME_REPOS"

# cd to Work directory
alias cdw="cd $HOME_WORK"

# cd to Projects directory
alias cdp="cd $HOME_PROJECTS"

# cd to LLogging directory
alias cdllog="cd $HOME_LLOG"

# cd to Start directory (tmux)
alias cds="cd $START_DIR"
