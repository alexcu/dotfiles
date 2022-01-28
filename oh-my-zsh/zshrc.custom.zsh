# Always use emacs
export EDITOR='emacs'
export VISUAL='emacs'

# Prefer /usr/local/bin over /usr/bin for brew installs
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.jenv/bin:$PATH"
export PATH="/usr/local/opt/sqlite/bin:$PATH"
export PATH="$PATH:/Users/Alex/Library/Application Support/Coursier/bin"

# Aliases & Functions
vnc() { open vnc://$1 }
call() { ~/.dotfiles/call $1 }
facetime() { open facetime://$1 }
alias timestamp="date +%FT%H%M%S"
alias vm="ssh vm"
alias vpn="~/.dotfiles/vpn"
alias cdu="cd .."
alias cdd="cd ~/Desktop"
alias cdl="cd ~/Downloads"
alias cdb="cd -"
alias zshconfig="emacs ~/.zshrc"
alias cpwd="pwd | pbcopy"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias sleepdisplay="pmset displaysleepnow"
alias ekb="less ~/iCloud/Apps/dotfiles/emacs/emacs-keybindings.txt"
alias c="cheat"

# Git
alias gweb="gh repo view -w"
alias ghash="git rev-parse --short HEAD"
alias gacp="ga -ip && gc && ggpush && ghash | pbcopy"
function gfk() {
  fork=${1:-alex-cummaudo}
  neworigin=$(git remote get-url origin | sed -E "s/git.realestate.com.au:[^\/]+\//git.realestate.com.au:$fork\//g")
  git remote rename origin upstream && git remote add origin $neworigin
  git remote -v
}
function gpup() {
  git pull --rebase upstream master
}
alias gcbup="gco master && gpup && gcb $1"

# Initialise rbenv + pyenv + jenv
if [ -x "$(command -v rbenv)" ]; then eval "$(rbenv init -)"; fi
if [ -x "$(command -v pyenv)" ]; then eval "$(pyenv init --path)"; fi
if [ -x "$(command -v jenv)"  ]; then eval "$(jenv init -)"; fi

# Don't auto-update Brew, instead use brewautoupate
# See https://apple.stackexchange.com/a/353010
export HOMEBREW_NO_AUTO_UPDATE=1

# Individual tab histories
setopt noappendhistory
setopt no_share_history
unsetopt inc_append_history
unsetopt share_history

# Architecture Changes
m1() { arch -arm64 $1 }
intel() { arch -x86_64 $1 }

# Homebrew on M1 - iBrew for Rosetta Brew
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
alias ibrew='arch -x86_64 /usr/local/bin/brew'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# REA
export REA_AS_MFA_METHOD=OKTA_PUSH
alias ssp='cd ~/repos/cx/stack-stars-projects'
