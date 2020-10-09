# Always use emacs
export EDITOR='emacs'
export VISUAL='emacs'

# Prefer /usr/local/bin over /usr/bin for brew installs
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.jenv/bin:$PATH"
export PATH="/usr/local/opt/sqlite/bin:$PATH"

# Aliases & Functions
vnc() { open vnc://$1 }
alias vpn="~/.dotfiles/vpn"
alias cdd="cd ~/Desktop"
alias zshconfig="emacs ~/.zshrc"
alias cpwd="pwd | pbcopy"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias sleepdisplay="pmset displaysleepnow"

# Initialise rbenv + pyenv + jenv
if [ -x "$(command -v rbenv)" ]; then eval "$(rbenv init -)"; fi
if [ -x "$(command -v pyenv)" ]; then eval "$(pyenv init -)"; fi
if [ -x "$(command -v jenv)"  ]; then eval "$(jenv init -)"; fi
