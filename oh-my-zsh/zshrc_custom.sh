# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='emacs'
fi

# Prefer /usr/local/bin over /usr/bin for brew installs
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.jenv/bin:$PATH"

#
# Functions
#

# Easy VNC
vnc() { open vnc://$1 }

# List my repos
repos() { cd ~/repos/$1; ls }

# CD to Desktop
cdd() { cd ~/Desktop }

# Ssh via back to my mac (btmm)
btmm_account_no()
{
  PIDFILE=$(mktemp)
  ACCNO=$(sed -n '/^[ ->]*\([0-9]\{10\}\)$/{s//\1/p;q;}' <(dns-sd -E & echo $! >> $PIDFILE))
  kill $(cat $PIDFILE)
  rm $PIDFILE
  echo $ACCNO
}
sshmac() { ssh Alex@$1.$(btmm_account_no).members.btmm.icloud.com }

# Edit this file
alias zshconfig="emacs ~/.zshrc"

#
# Aliases
#

# Repositories
alias dfire-api="cd ~/repos/doubtfire/doubtfire-api"
alias dfire-web="cd ~/repos/doubtfire/doubtfire-web"

# Apps
alias color="osascript '/Users/Alex/Library/Mobile Documents/com~apple~ScriptEditor2/Documents/ColorPicker.scpt'"
alias texpad="open -a Texpad"

# Service Shortcuts
alias cpwd="pwd | pbcopy"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias sleepdisplay="pmset displaysleepnow"

#
# Evals
#

# User configuration
eval "$(/usr/libexec/path_helper -s)"

# Initialise rbenv + pyenv + jenv
eval "$(rbenv init -)"
eval "$(pyenv init -)"
#eval "$(jenv init -)"

export PATH="/usr/local/opt/sqlite/bin:$PATH"