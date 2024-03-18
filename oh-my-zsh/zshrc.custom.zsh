# Always use emacs
export EDITOR='emacs'
export VISUAL='emacs'

# Initialise rbenv + pyenv + jenv
#if [ -x "$(command -v rbenv)" ]; then eval "$(rbenv init -)"; fi
if [ -x "$(command -v pyenv)" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi
#if [ -x "$(command -v jenv)"  ]; then eval "$(jenv init -)"; fi

# Prefer /usr/local/bin over /usr/bin for brew installs
#export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
#export PATH="$HOME/.jenv/bin:$PATH"
#export PATH="/usr/local/opt/sqlite/bin:$PATH"
#export PATH="$PATH:/Users/Alex/Library/Application Support/Coursier/bin"

# Fig
export PATH="$PATH:~/.local/bin"

# Additional keybindings - refer to https://zsh.sourceforge.io/Guide/zshguide04.html
bindkey "^w" kill-region
function toggle-right-prompt() { p10k display '*/right'=hide,show; }
zle -N toggle-right-prompt
bindkey '^P' toggle-right-prompt

# Aliases & Functions
vnc() { open vnc://$1 }
call() { ~/.dotfiles/call $1 }
facetime() { open facetime://$1 }
findme() { grep --color=always -irn "$1" . }
alias timestamp="date +%FT%H%M%S"
alias timestampd="timestamp | sed 's/-//g'"
alias timestampint="date +%Y%m%d%H%M"
alias datestamp="date +%F"
alias datestampd="datestamp | sed 's/-//g'"
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
alias emacskb="less ~/iCloud/Apps/dotfiles/emacs/emacs-keybindings.txt"
alias color="osascript -e 'choose color' &"
alias jqless="jq -C | less -R"

# Git(Hub)
alias gcpersonal="git -c user.email=alexcu@me.com $1"
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
