#! /usr/bin/env zsh

#
# Utility aliases
#

# Make aliases easier to look up
alias a="als"

# What3Words-like identifier to use for unique identifiers
function w3w() {
    local wordlist=""
    local candidate=""
    for candidate in "${WORDLIST:-}" "/usr/share/dict/words" "/usr/dict/words" "/usr/share/dict/web2"; do
        if [[ -n "$candidate" && -f "$candidate" ]]; then
            wordlist="$candidate"
            break
        fi
    done

    if [[ -z "$wordlist" ]]; then
        echo "w3w: no wordlist found (set WORDLIST or install one, e.g. 'wamerican'/'words')" >&2
        return 1
    fi

    local shuf_cmd=""
    if command -v shuf >/dev/null 2>&1; then
        shuf_cmd="shuf"
    elif command -v gshuf >/dev/null 2>&1; then
        shuf_cmd="gshuf"
    elif command -v python3 >/dev/null 2>&1; then
        WORDLIST_FILE="$wordlist" python3 - <<'PY'
import os, random, re, sys
path = os.environ.get("WORDLIST_FILE")
if not path:
    sys.exit(1)
with open(path, "r", errors="ignore") as f:
    words = [w.strip().lower() for w in f if re.fullmatch(r"[A-Za-z]{3}", w.strip())]
if not words:
    sys.exit(1)
print("-".join(random.choice(words) for _ in range(3)))
PY
        return $?
    else
        echo "w3w: need one of shuf, gshuf, or python3" >&2
        return 1
    fi

    # Filter the word list to include words that are exactly 3 characters long
    filtered_wordlist=$(grep -E '^[a-zA-Z]{3}$' "$wordlist" 2>/dev/null || true)
    if [[ -z "$filtered_wordlist" ]]; then
        echo "w3w: no 3-letter words found in $wordlist" >&2
        return 1
    fi

    # Function to find three words of exactly 3 characters
    word1=$(echo "$filtered_wordlist" | "$shuf_cmd" -n 1 | tr '[:upper:]' '[:lower:]')
    word2=$(echo "$filtered_wordlist" | "$shuf_cmd" -n 1 | tr '[:upper:]' '[:lower:]')
    word3=$(echo "$filtered_wordlist" | "$shuf_cmd" -n 1 | tr '[:upper:]' '[:lower:]')

    # Combine the words with dots
    random_identifier="${word1}-${word2}-${word3}"

    # Output the identifier
    echo "$random_identifier"
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

# Watch
alias w="watch"
alias doit="watch -n 1 --"

# Claude (non-npm)
alias claude="$HOME/.claude/local/claude"

# Confirm before quitting ncdu always
alias ncdu="ncdu --confirm-quit"


# Keep clamshell mode alive.
function clamshell() {
    local force=""
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: clamshell [-f] [seconds]"
        echo "Keep the system awake, even with the lid shut."
        echo "The display still sleeps on its timer and blanks on lid close."
        echo "  -f: allow on battery"
        echo "  seconds: auto-stop after seconds"
        return 0
    fi
    if [[ "$1" == "-f" || "$1" == "--force" ]]; then
        force=1
        shift
    fi
    local duration="${1:-}"
    if [[ -n "$duration" && "$duration" != <-> ]]; then
        echo "clamshell: duration must be in seconds, got '$duration'" >&2
        return 1
    fi

    if [[ -z "$force" ]] && ! pmset -g batt | grep -q "AC Power"; then
        echo "clamshell: on battery, refusing to disable sleep (-f to override)" >&2
        return 1
    fi

    sudo pmset -a disablesleep 1 || return 1

    sudo -b sh -c '
        trap "" HUP
        prior_sleeps=$(pmset -g log | grep -c "Entering Sleep state")
        on_battery_secs=0
        elapsed=0
        prev_lid=0
        while pmset -g | grep -qE "SleepDisabled[[:space:]]+1" \
            && kill -0 "$1" 2>/dev/null \
            && [ "$on_battery_secs" -lt 60 ] \
            && { [ -z "$2" ] || [ "$elapsed" -lt "$2" ]; }; do
            sleep 5
            elapsed=$((elapsed + 5))
            if [ -n "$3" ] || pmset -g batt | grep -q "AC Power"; then
                on_battery_secs=0
            else
                on_battery_secs=$((on_battery_secs + 5))
            fi
            if ioreg -r -k AppleClamshellState -d 1 \
                | grep -q "AppleClamshellState. = Yes"; then
                lid=1
            else
                lid=0
            fi
            if [ "$lid" = 1 ] && [ "$prev_lid" = 0 ]; then
                pmset displaysleepnow
            fi
            prev_lid=$lid
        done
        # Announce before re-enabling sleep: say blocks until playback
        # finishes, and the machine may sleep as soon as disablesleep is 0.
        # Respects mute: no announcement when output is muted.
        if [ "$on_battery_secs" -ge 60 ]; then
            say -v Fred "Computer going to sleep"
        fi
        pmset -a disablesleep 0
        pkill -P "$1" caffeinate 2>/dev/null
        sleep 15
        pmset -g log | grep "Entering Sleep state" \
            | tail -n +$((prior_sleeps + 1)) | sed "s/^/clamshell: slept at /"
    ' clamshell-watchdog $$ "$duration" "$force" 2>/dev/null

    trap 'sudo pmset -a disablesleep 0' EXIT INT TERM
    if [[ -n "$duration" ]]; then
        caffeinate -i -t "$duration"
    else
        caffeinate -i
    fi
}

# Blep logs
function bslogs() {
    ssh alex@blepserve "/usr/bin/log stream --style compact --predicate 'eventMessage CONTAINS[c] \"network\"'"
}
