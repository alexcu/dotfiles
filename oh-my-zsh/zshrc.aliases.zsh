#!/usr/bin/env zsh

# Timestamps
alias timestamp="date +%FT%H%M%S"
alias timestampd="timestamp | sed 's/-//g'"
alias timestampint="date +%Y%m%d%H%M"
alias datestamp="date +%F"
alias datestampd="datestamp | sed 's/-//g'"

# cd Suffixes
alias cdu="cd .."
alias cdd="cd ~/Desktop"
alias cdl="cd ~/Downloads"
alias cdb="cd -"
alias cdr="cd ~/repos"
alias cdw="cd ~/repos/work"

# Config edit shortcuts
alias zshconfig="emacs ~/.zshrc"
alias dotfiles="code ~/.dotfiles"
alias emacsconfig="emacs ~/.emacs"

# Applications
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias sleepd="pmset displaysleepnow"
alias c="cheat"
alias color="osascript -e 'choose color' &"
alias jqless="jq -C | less -R"

# Git(Hub)
alias gper="git -c user.email=alexcu@me.com $1"
alias gweb="gh repo view -w"
alias ghash="git rev-parse --short HEAD"
alias ggpushash="ggpush && ghash | pbcopy"
alias gacp="ga -ip && gc && ggpush && ghash | pbcopy"
alias gres="ga -ip ; gc ; ggpush && ghash | xargs echo 'Resolved in' | pbcopy"
alias gbname="git rev-parse --abbrev-ref HEAD"
alias gbprefix="gbname | grep -oE '^([a-zA-Z]{1,5})-?(\d+)'"
alias gcbup="gco master || gco main && gpup && gcb $1"
alias gcbor="gco master || gco main && gpor && gcb $1"
function gpup() {
  git pull --rebase upstream master || git pull --rebase upstream main
}
function gpor() {
  git pull --rebase origin master || git pull --rebase origin main
}

# Work with the *N*ewest *F*ile
# E.g., tar xf NF; cd NF
alias -g NF='./*(oc[1])'
