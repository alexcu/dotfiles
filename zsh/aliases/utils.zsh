#! /usr/bin/env zsh

#
# Utility aliases
#

# Make aliases easier to look up
alias a="als"

# What3Words-like identifier to use for unique identifiers
function w3w() {
    # Get random words from the dictionary
    wordlist="/usr/share/dict/words"

    # Filter the word list to include words that are exactly 3 characters long
    filtered_wordlist=$(grep -E '^[a-zA-Z]{3}$' $wordlist)

    # Function to find three words of exactly 3 characters
    word1=$(echo "$filtered_wordlist" | shuf -n 1 | tr '[:upper:]' '[:lower:]')
    word2=$(echo "$filtered_wordlist" | shuf -n 1 | tr '[:upper:]' '[:lower:]')
    word3=$(echo "$filtered_wordlist" | shuf -n 1 | tr '[:upper:]' '[:lower:]')

    # Combine the words with dots
    random_identifier="${word1}-${word2}-${word3}"

    # Output the identifier
    echo $random_identifier
}

# Vscode
alias vs="code"

# vd CSV explorer
alias csv="vd"

# Zsh! (reload zshrc)
alias zsh\!="echo Removing $ZSH_COMDUMP... && rm $ZSH_COMDUMP && echo -n Sourcing $HOME/.zshrc... && source $HOME/.zshrc > /dev/null && echo Done!"

# Lock screen
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Sleep display
alias sleepd="pmset displaysleepnow"

# Cheat
alias c="cheat"

# Color picker
alias color="osascript -e 'choose color' &"

# Jq less
alias jqless="jq -C | less -R"

# Hide files
alias hide="chflags hidden ."

# Unhide files
alias unhide="chflags nohidden ."

# Brew update and upgrade
alias bubu="brew update && brew upgrade"

# Dock spacer
alias dockspacer="defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type=\"small-spacer-tile\";}' && killall Dock"

# Debugpy
function dpython3 () {
    local listen_at=${DEBUGPY_HOST-"localhost:5678"}
    echo "Starting debugpy to listen at $listen_at..."
    PYDEVD_DISABLE_FILE_VALIDATION=1 debugpy --listen "$listen_at" --wait-for-client "$@"
}

# Clear terminal
alias k="clear"

# Returns the *l*ast *m*odified file
# E.g., tar xf $(lm); cd $(lm)' or cd LM if in caps
alias -g LF='./*(oc[1])'
function lm() {
    gls -Art $@ | tail -n1
}

# Retry command until it succeeds
function retry() {
  until eval "$@"; do
    echo "Command failed. Retrying..."
    sleep 1
  done
}
alias rt="retry"

# Architecture Changes
alias m1='arch -arm64'
alias intel='arch -x86_64'

# Make directories in sudo-only places and own
function mkdirown() {
    sudo mkdir -p $1 && sudo chown $USER $1
}

# Realpath and basename
alias rp="realpath"
alias bn="basename"

# Defaultbrowser
alias db="defaultbrowser"
alias dbs="defaultbrowser safari"
alias dba="defaultbrowser browser" # Arc
