# Make aliases easier to look up
alias a="als"

# Timestamps
alias timestamp="date +%FT%H%M%S"
alias timestampd="$(date +%FT%H%M%S | sed 's/-//g')"
alias timestampint="date +%Y%m%d%H%M"
alias datestamp="date +%F"
alias datestampd="$(date +%F | sed 's/-//g')"

# Tilde suffixes
alias \~d="$HOME/Desktop"
alias \~l="$HOME/Downloads"
alias \~r="$HOME/repos"
alias \~rw="$HOME/repos/work"
alias \~s="$HOME/.scripts"

# cd Suffixes
alias cdu="cd .."
alias cdb="cd -"
alias cdd="cd ~d"
alias cdl="cd ~l"
alias cdr="cd ~r"
alias cdw="cd ~rw"
alias cds="cd ~s"

# Config edit shortcuts
alias cfg_zsh="emacs ~/.zshrc"
alias cfg_dot="code ~/.dotfiles"
alias cfg_emacs="emacs ~/.emacs"
alias cfg_als="emacs ~/.zshrc.aliases.zsh"

# Applications
alias rzsh="source ~/.zshrc"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias sleepd="pmset displaysleepnow"
alias c="cheat"
alias color="osascript -e 'choose color' &"
alias jqless="jq -C | less -R"
alias dir_hide="chflags hidden ."
alias dir_unhide="chflags nohidden ."
alias bubu="brew update && brew upgrade"

# Ports
function whichport() { lsof -ti :$1 }
function killport() { kill $(lsof -ti :$1) }

# Scripts
for script in $HOME/.scripts/*; do
    if [[ -f $script ]]; then
        filename=$(basename "$script")
        alias "scr_$filename"="$script"
    fi
done

# Git(Hub)
alias gapar="gapa && gc && ggpushs"
alias gar="git ls-files -u | awk '{print \$4}' | sort -u | xargs git add"
alias gbc="git branch --copy"
alias gbn="git symbolic-ref --short HEAD"
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
alias ggpushsr="ggpush && ghsr && ggpushnotify"
alias ghs="git rev-parse --short HEAD"
alias ghsr="(ghs | xargs echo 'Resolved in') | pbcopy"
alias gper="git -c user.email=alexcu@me.com $1"
alias gpor="git pull --rebase origin master || git pull --rebase origin main"
alias gprt="git pr-train"
alias gprtc="emacs ./.pr-train.yml"
alias gprtp="git pr-train -p"
alias gprtpr="git pr-train -p --create-prs --draft"
alias gpup="git pull --rebase upstream master || git pull --rebase upstream main"
alias grsta="git restore --staged ."
alias gweb="gh repo view -w"
# Supress warnings for $(gbn) call if not in git repo
{
  alias gbcn="git branch --copy $(gbn)"
  alias gbct="git branch --copy $(gbn) _tmp_$(gbn)"
  alias gbcz="git branch --copy $(gbn) m/$(gbn)"
  alias gbmn="git branch --move $(gbn)"
  alias gbmt="git branch --move $(gbn) _tmp_$(gbn)"
  alias gbmz="git branch --move $(gbn) m/$(gbn)"
} 2>/dev/null
export gbcn gbct gbcz gbmn gbmt gbmz

# Work with the *N*ewest *F*ile
# E.g., tar xf NF; cd NF
alias -g NF='./*(oc[1])'
