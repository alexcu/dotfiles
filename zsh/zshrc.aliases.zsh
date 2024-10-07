#!/usr/bin/env zsh

#
# Personal aliases, functions, and exports
#

# Make aliases easier to look up
alias a="als"

# Timestamps
alias timestamp="date +%FT%H%M%S"
alias timestampd="$(date +%FT%H%M%S | sed 's/-//g')"
alias timestampint="date +%Y%m%d%H%M"
alias datestamp="date +%F"
alias datestampd="$(date +%F | sed 's/-//g')"

# Common HOME paths
export HOME_DESKTOP="$HOME/Desktop"
export HOME_DOTFILES="$HOME/.dotfiles"
export HOME_WORK_DOTFILES="$HOME/.zshrc.work.zsh"
export HOME_DOWNLOADS="$HOME/Downloads"
export HOME_REPOS="$HOME/repos"
export HOME_GIT_WORKTREES="$HOME_REPOS/worktrees"
export HOME_WORK="$HOME/work"
export HOME_SCRIPTS="$HOME/.scripts"

# Tilde suffixes
alias \~d="$HOME_DESKTOP"
alias \~l="$HOME_DOWNLOADS"
alias \~r="$HOME_REPOS"
alias \~w="$HOME_WORK"
alias \~s="$HOME_SCRIPTS"

# cd Suffixes
alias cdu="cd .."
alias cdb="cd -"
alias cdd="cd $HOME_DESKTOP"
alias cdl="cd $HOME_DOWNLOADS"
alias cdr="cd $HOME_REPOS"
alias cdw="cd $HOME_WORK"
alias cds="cd $HOME_SCRIPTS"

# Config edit shortcuts
_cfg_zsh() {
    echo Unlocking .zshrc for edits...
    sudo chflags nouchg ~/.zshrc
    emacs $HOME/.zshrc
    echo Locking down .zshrc for edits...
    sudo chflags uchg ~/.zshrc
}
alias cfg_zsh="_cfg_zsh"
alias cfg_dot="code $HOME_DOTFILES"
alias cfg_emacs="emacs $HOME/.emacs"
alias cfg_als="emacs $HOME/.zshrc.aliases.zsh"
alias cfg_scr="code $HOME_SCRIPTS"

# Prefix for all executable scripts in $HOME_SCRIPTS
for script in $HOME_SCRIPTS/*; do
    if [[ -f $script && -x $script ]]; then
        filename=$(basename "$script")
        alias "scr_$filename"="$script"
    fi
done

# tmux aliases
alias tpn="tmux select-pane -T"

# Applications
alias vs="code"
alias rzsh="source ~/.zshrc"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias sleepd="pmset displaysleepnow"
alias c="cheat"
alias color="osascript -e 'choose color' &"
alias jqless="jq -C | less -R"
alias hide="chflags hidden ."
alias unhide="chflags nohidden ."
alias bubu="brew update && brew upgrade"

# Ports
function whatport() { lsof -ti :$1 }
function killport() { lsof -ti :$1 | xargs kill }
function waitport() {
  [[ "$#" -lt 3 || "$2" != "--" ]] && { echo "Usage: waitfor [port] -- [cmd]"; return 1; }
  
  local port="$1"
  shift 2
  
  while [[ -z $(whatport "$port") ]]; do
    sleep 1
  done

  "$@"
}

# Git(Hub)
alias gar="git ls-files -u | awk '{print \$4}' | sort -u | xargs git add"
alias gb="git branch | grep -v '^\s*z/'"
alias gbc="git branch --copy"
alias gC="git commit --message \""
alias gcbor="(gco master || gco main) && gpor && gcb $1"
alias gcbup="(gco master || gco main) && gpup && gcb $1"
alias gcleanfi="git clean -fi"
alias gco\!="git checkout -- "
alias gcoa\!="git checkout -- ."
alias gcob="git checkout @{-1}"
alias gcom="git checkout master"
alias gcpn="git cherry-pick --no-commit"
alias gcpn="git cherry-pick --no-commit"
alias gcpn="git cherry-pick --no-commit"
alias ggpushnotify="notify Changes have been pushed"
alias ggpushs="ggpush && (ghs | pbcopy) && ggpushnotify"
alias ggpushsr="ghsr && ggpush && ggpushnotify"
alias ghs="git rev-parse --short HEAD"
alias ghsr="(ghs | xargs echo 'Resolved in') | pbcopy"
alias ghpr="gh pr"
alias ghprc="gh pr create --web"
alias gper="git -c user.email=alexcu@me.com $1"
alias gpor="git pull --rebase origin master || git pull --rebase origin main"
alias gprt="git pr-train"
alias gprtc="emacs ./.pr-train.yml"
alias gprtp="git pr-train -p"
alias gprtpr="git pr-train -p --create-prs --draft"
alias gpup="git pull --rebase upstream master || git pull --rebase upstream main"
alias grsta="git restore --staged ."
alias gweb="gh repo view -w"

function gA() {
    gapa && git commit --message "$1" && ggpushsr
}

# Define gbn function to return current branch or nothing if not in a git repo
function gbn() {
    git symbolic-ref --short HEAD 2>/dev/null
}

# Precmd hook to refresh aliases based on the current branch every time the prompt is shown
precmd() {
    local branch_name="$(gbn)"
    
    if [[ -n $branch_name ]]; then
        alias gbcn="git branch --copy $branch_name"
        alias gbct="git branch --copy $branch_name _tmp_$branch_name"
        alias gbcz="git branch --copy $branch_name z/$branch_name"
        alias gbmn="git branch --move $branch_name"
        alias gbmt="git branch --move $branch_name _tmp_$branch_name"
        alias gbmz="git branch --move $branch_name z/$branch_name"
	alias gwta="git worktree add $HOME_GIT_WORKTREES/$(basename $(git rev-parse --show-toplevel))/$branch_name $branch_name"
    else
        unalias gbcn gbct gbcz gbmn gbmt gbmz gwta 2>/dev/null
    fi
}



# Work with the *N*ewest *F*ile
# E.g., tar xf NF; cd NF
alias -g NF='./*(oc[1])'

# Notifications
function notify() {
    /usr/bin/osascript -e "display notification \"$*\""
}

# Always use emacs
export EDITOR='emacs'
export VISUAL='emacs'

# Prefer /usr/local/bin over /usr/bin for brew installs
export PATH="$HOME/.pyenv/bin:$PATH"

# Don't auto-update Brew, instead use brewautoupate
# See https://apple.stackexchange.com/a/353010
export HOMEBREW_NO_AUTO_UPDATE=1

# Architecture Changes
alias m1='arch -arm64'
alias intel='arch -x86_64'

# Homebrew on M1 - iBrew for Rosetta Brew
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
alias ibrew='arch -x86_64 /usr/local/bin/brew'

# Colorize shell
ZSH_COLORIZE_STYLE="xcode"
export CLICOLOR=1
alias l='ls -lahG'
alias cat='ccat'
