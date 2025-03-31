#!/usr/bin/env zsh

#
# Personal aliases, functions, and exports
#

# Make aliases easier to look up
alias a="als"

# Colour echo (cecho red "foo")
function cecho() {
    local color=$1
    shift
    if [[ -n ${fg[$color]} ]]; then
        echo -e "${fg[$color]}$@${reset_color}"
    elif [[ "$color" =~ ^[0-9]+$ ]] && [ "$color" -ge 0 ] && [ "$color" -le 255 ]; then
        echo -e "\e[38;5;${color}m$@${reset_color}"
    else
        echo "Color '$color' not found."
    fi
}

# Aliases for named foreground colours
# Use print -P to process ANSI escape sequences
alias cred='print -P "%F{red}"'
alias cgreen='print -P "%F{green}"'
alias cyellow='print -P "%F{yellow}"'
alias cblue='print -P "%F{blue}"'
alias cmagenta='print -P "%F{magenta}"'
alias ccyan='print -P "%F{cyan}"'
alias cwhite='print -P "%F{white}"'
alias creset='print -P "%f"'

# Function to print all available colors
function print_all_colors() {
    echo "Named Colors:"
    for color in ${(k)fg}; do
        echo -e "${fg[$color]}$color${reset_color}: This is $color text"
    done

    echo ""
    echo "256-Color Palette:"
    for i in {0..255}; do
        printf "\e[38;5;${i}m%-6s\e[0m" "$i"
        # Print 6 colors per line for better formatting
        if (( (i + 1) % 6 == 0 )); then
            echo ""
        fi
    done
    echo ""  # Add a newline at the end
}

# What3Words-like identifier
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

# Colored moreutils ts, useful for piping
export LOGGING_TIMESTAMP_FORMAT="[%F %.T]"
# Human-readable timestamp: [2024-10-15 15:07:28]
alias tsh="date +%F' '%T"
# Extended timestamp with milliseconds [2024-10-15 15:07:28.123]
alias tsx="date +'%Y-%m-%d %H:%M:%S.%3N'"
# Compact timestamp with no delimiters: 20241015150819
alias tsc="date +%Y%m%dT%H%M%S"
# Timestamp identifier suffixed with word-based identifier
alias tsid="echo $(tsc)_$(w3w)"
# Unix timestamp: 1734312008
alias tsu="date +%s"
# Human-readable datestamp: 2024-10-15
alias dsh="date +%F"
# Compact datestamp: 20241015
alias dsc="date +%Y%m%d"
# Date identifier suffixed with word-based identifier
alias dsid="echo $(dsc)_$(w3w)"
# Quickly get days until something
function daysuntil() {
    local today=$(date +%Y-%m-%d)  # Default start date is today
    local target_date=""
    local start_date=""
    local show_days_only=false

    # Parse parameters
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -d) show_days_only=true ;;
            -t) start_date="$2"; shift ;;
            *) target_date="$1" ;;
        esac
        shift
    done

    # If no start date is provided with -t, use today's date
    if [[ -z "$start_date" ]]; then
        start_date=$today
    fi

    # Ensure the target date is provided
    if [[ -z "$target_date" ]]; then
        echo "Usage: daysuntil [target_date] [-d] [-t start_date]"
        return 1
    fi

    # If -d is provided, show only days
    if [[ "$show_days_only" = true ]]; then
        ddiff "$start_date" "$target_date" -f '%d days'
    else
        # Get the full result in years, months, weeks, and days
        result=$(ddiff "$start_date" "$target_date" -f '%y years, %m months, %w weeks, %d days')

        # Remove components that are 0 (like "0 years", "0 months")
        result=$(echo "$result" | sed -E 's/\b0 (years?|months?|weeks?|days?)\b[,]?//g' | sed 's/ ,/,/g' | sed 's/, *$//; s/^, *//')
        echo "$result"
    fi
}

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

# Tilde suffixes
alias \~d="$HOME_DESKTOP"
alias \~l="$HOME_DOWNLOADS"
alias \~r="$HOME_REPOS"
alias \~w="$HOME_WORK"
alias \~s="$HOME_SCRIPTS"
alias \~p="$HOME_PROJECTS"
alias \~llog="$HOME_LLOG"

# cd Suffixes
alias cdu="cd .."
alias cdb="cd -"
alias cdd="cd $HOME_DESKTOP"
alias cdl="cd $HOME_DOWNLOADS"
alias cdr="cd $HOME_REPOS"
alias cdw="cd $HOME_WORK"
alias cdp="cd $HOME_PROJECTS"
alias cdllog="cd $HOME_LLOG"
alias cds="cd $START_DIR"

# Config edit shortcuts
_cfg_zsh() {
    echo Unlocking .zshrc for edits...
    sudo chflags nouchg ~/.zshrc
    $EDITOR $HOME/.zshrc
    echo Locking down .zshrc for edits...
    sudo chflags uchg ~/.zshrc
}
alias cfg_zsh="_cfg_zsh"
alias cfg_dot="code $HOME_DOTFILES"
alias cfg_emacs="$EDITOR $HOME/.emacs"
alias cfg_tmux="$EDITOR $HOME/.tmux.conf"
alias cfg_als="$EDITOR $HOME/.zshrc.aliases.zsh"
alias cfg_scr="code $HOME_SCRIPTS"

# Prefix for all executable scripts in $HOME_SCRIPTS
for script in $HOME_SCRIPTS/*; do
    if [[ -f $script && -x $script ]]; then
        filename=$(basename "$script")
        alias "scr_$filename"="$script"
    fi
done

# tmux aliases
alias tip="$HOME/.tmux.pane.init"
function tip!() { tip "$@" && clear }
alias tpt="tmux display -p '#S:#I.#P'"

# Logging
export LLOG_DIR="$HOME_LLOG"
function cts() {
    ts "$(cred)$LOGGING_TIMESTAMP_FORMAT$(creset)"
}
function llog() {
    local stream="${1:-$LLOG_STREAM}"

    if [ -z "$stream" ]; then
        echo "Error: No log stream specified. Wrap substreams or multiline commands in quotes."
        echo "Usage:  cmd logstream | llog  OR  llog logstream -- 'cmd'"
        return 1
    fi

    log_dir="$LLOG_DIR/$stream"
    mkdir -p "$log_dir"

    log_file="$log_dir/$(tsid).log"
    logit() {
        ts "$LOGGING_TIMESTAMP_FORMAT" \
        | tee >(cat >> "$log_file") \
        | bat --paging=never --style=plain -l log
    }

    ## Check if the "--" exists, and handle command execution
    if [[ " $* " =~ " -- " ]]; then
        # Extract all arguments after "--"
        command="${*#*-- }"
        eval "$command" 2>&1 | logit
    else
        # Log piped input if no command is passed
        logit
    fi
}
function lmlog() {
    lm $LLOG_DIR/$@/**/*.log
}
function slog() {
    bat $(lmlog $1) -l log
}
function tlog() {
    tail -f $(lmlog $1) | bat --paging=never --style=plain -l log
}

# Applications
alias vs="code"
alias csv="vd"
alias zsh\!="echo Removing $ZSH_COMDUMP... && rm $ZSH_COMDUMP && echo -n Sourcing $HOME/.zshrc... && source $HOME/.zshrc > /dev/null && echo Done!"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias sleepd="pmset displaysleepnow"
alias c="cheat"
alias color="osascript -e 'choose color' &"
alias jqless="jq -C | less -R"
alias hide="chflags hidden ."
alias unhide="chflags nohidden ."
alias bubu="brew update && brew upgrade"
alias dockspacer="defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type=\"small-spacer-tile\";}' && killall Dock"
function dpython3 () {
    local listen_at=${DEBUGPY_HOST-"localhost:5678"}
    echo "Starting debugpy to listen at $listen_at..."
    PYDEVD_DISABLE_FILE_VALIDATION=1 debugpy --listen "$listen_at" --wait-for-client "$@"
}

# Ports
function whatport() { lsof -ti :$1 }
function killport() { lsof -ti :$1 | xargs kill }
function waitport() {
  [[ "$#" -lt 1 ]] && { echo "Usage: waitport [port] [-- [cmd]]"; return 1; }

  local port="$1"
  shift

  if [[ "$1" == "--" ]]; then
    shift
  fi

  echo -n "Waiting for port $port to be opened..."

  while [[ -z $(whatport "$port") ]]; do
    sleep 1
  done

  echo " success! (pid=$(whatport "$port"))"

  if [[ "$#" -gt 0 ]]; then
    "$@"
  fi
}

# Confirm
function confirm() {
    local prompt="${1:-}"
    if [[ -n "$prompt" ]]; then
        echo -n "${prompt}"   # Print the custom prompt without a newline
        echo                  # Move to a new line
    fi
    read -s -k 1 -p "Press Enter to continue..."
    echo
}

# Git(Hub)
alias gad="git add --all && git commit --message '.'"
alias gar="git ls-files -u | awk '{print \$4}' | sort -u | xargs git add"
alias gb="git branch | grep -v '^\s*z/' | fzf"
alias gbc="git branch --copy"
alias gC="git commit --message \""
alias gcbor="(gco master || gco main) && gpor && gcb $1"
alias gcbup="(gco master || gco main) && gpup && gcb $1"
alias gcd="git commit --message '.'"
alias gcleanfi="git clean -fi"
alias gco\!="git checkout -- "
alias gcoa\!="git checkout -- ."
alias gcob="git checkout @{-1}"
alias gcobr="gb | xargs git checkout"
alias gcom\!="git checkout master"
alias gcom="gfm && git checkout master"
alias gcom="git checkout master"
alias gcpn="git cherry-pick --no-commit"
alias gcpn="git cherry-pick --no-commit"
alias gcpn="git cherry-pick --no-commit"
alias gd="git diff --"
alias gD="git diff"
alias gfm="git fetch origin master:master"
alias ggpushnotify="notify Changes have been pushed"
alias ggpushper="ssh-add ~/.ssh/id_rsa_personal && ggpush &&  ssh-add -d  ~/.ssh/id_rsa_personal"
alias ggpushs="ggpush && (ghs | pbcopy) && ggpushnotify"
alias ggpushsr="ghsr && ggpush && ggpushnotify"
alias ghpr="gh pr"
alias ghprc="gh pr create --web"
alias ghprw="gh pr view --web"
alias ghs="git rev-parse --short HEAD"
alias ghsr="(ghs | xargs echo 'Resolved in') | pbcopy"
alias gmm="git merge origin master"
alias gmnc="git merge --no-commit"
alias gper="git -c user.email=alexcu@me.com $1"
alias gpor="git pull --rebase origin master || git pull --rebase origin main"
alias gprt="git pr-train"
alias gprtc="$EDITOR ./.pr-train.yml"
alias gprtp="git pr-train -p"
alias gprtpr="git pr-train -p --create-prs --draft"
alias gpup="git pull --rebase upstream master || git pull --rebase upstream main"
alias grbm="git rebase master"
alias grsta="git restore --staged ."
alias gs="git stash"when
alias gt="git tag"
alias gweb="gh repo view -w"

# Check for git repo
function gig() {
    local repo_path=${1:-$(pwd)}
    git -C "$repo_path" rev-parse --is-inside-work-tree > /dev/null 2>&1
}

# Must unalias `git` plugin gwip
gunalias gwip 2>/dev/null
function gwip() {
    local force=0
    local base_branch="master"

    # Parse options
    while getopts "f" opt; do
      case ${opt} in
        f )
          force=1
          ;;
        \? )
          echo "Usage: gwip [-f] [base-branch]"
          return 1
          ;;
      esac
    done
    shift $((OPTIND -1))

    # Set the base branch if provided
    if [ -n "$1" ]; then
        base_branch="$1"
    fi

    # Check for changes unless -f is provided
    if [ "$force" -eq 0 ]; then
        if git diff-index --quiet HEAD; then
            echo "No changes to push a WIP commit. Aborting."
            return 1
        fi
    fi

    echo "Start git WIP push..."

    # Adding changes, exit on failure
    echo "Adding changes..."
    git add -A || { echo "Failed to add changes"; return 1; }

    # Determine the current branch and WIP branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD) || { echo "Failed to get current branch"; return 1; }
    local wip_branch="wip/$current_branch"
    local remote_branch="$current_branch"

    # Check if current branch is already a WIP branch, avoid nesting
    if [[ $current_branch == wip/* ]]; then
        wip_branch="$current_branch"
        remote_branch="${current_branch#*/}"
    else
        # Create WIP branch, exit on failure
        echo "Creating WIP branch: $wip_branch..."
        git checkout -b $wip_branch || { echo "Failed to create WIP branch"; return 1; }
    fi

    # Find the base WIP commit, exit on failure
    echo "Finding base WIP commit..."
    local base_wip_commit=$(git log --author=$(git config user.email) --grep="^wip$" -n 1 --pretty=format:"%H")

    if [ -n "$base_wip_commit"  ]; then
        echo "Found base WIP commit: $base_wip_commit"
        git commit --allow-empty --no-verify --no-gpg-sign --fixup=$base_wip_commit || { echo "Failed to create fixup commit"; return 1; }
    else
        echo "No WIP commit found, creating new one"
        git commit --allow-empty --no-verify --no-gpg-sign --message="wip" || { echo "Failed to create new WIP commit"; return 1; }
    fi

    # Fetch base branch, exit on failure
    echo "Fetching $base_branch..."
    git fetch origin $base_branch:$base_branch || { echo "Failed to fetch base branch $base_branch"; return 1; }

    # Rebase base branch, exit on failure
    echo "Rebasing $base_branch..."
    git rebase $base_branch || { echo "Rebase failed"; return 1; }

    # Push the WIP commit, exit on failure
    local remote_wip_branch="${remote_branch}-wip"
    echo "Pushing WIP commit to remote branch: $remote_wip_branch"
    git push --force origin $wip_branch:$remote_wip_branch || { echo "Failed to push WIP branch"; return 1; }

    echo "Squash all WIPs using: gwips $base_branch"
}
function gwips() {
    git rebase --interactive --autosquash ${1-master}
}

# fzf-git aliases
alias G="_fzf_git_files"
alias Gb="_fzf_git_branches"
alias Gh="_fzf_git_hashes"
alias Gr="_fzf_git_remotes"
alias Grf="_fzf_git_lreflogs"
alias Gs="_fzf_git_stashes"
alias Gt="_fzf_git_tags"
alias Gwt="_fzf_git_worktrees"

function gA() {
    gapa && git commit --message "$1" && ggpushsr
}

# Define gbn function to return current branch or nothing if not in a git repo
function gbn() {
    git symbolic-ref --short HEAD 2>/dev/null
}

# Set up a new worktree
function Gwta() {
    # Ensure the current directory is a Git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not in a Git repository" >&2
        return 1
    fi

    local repo=$(basename "$(git rev-parse --show-toplevel)")
    local base_branch="${2:-master}"
    local sparse_checkout_glob="${3:-/*\n!/exclude/}"
    local worktree="$1"
    local worktree_path="$HOME_GIT_WORKTREES/$repo/$worktree"
    local worktree_base_branch="$base_branch-$worktree"

    # Create a Git worktree
    echo "Fetching origin $base_branch first..."
    git fetch origin "$base_branch:$base_branch" || { echo "Error fetching base branch $base_branch!" >&2; return 1 }

    echo "Initialising new worktree $worktree based on branch $base_branch at $worktree_path..."
    git worktree add --no-checkout -b "$worktree_base_branch" "$worktree_path" || { echo "Error creating worktree!" >&2; return 1 }
    cd "$worktree_path" || { echo "Error, $worktree_path doesn't exist..." >&2; return 1 }
    git config core.sparseCheckout true
    echo $sparse_checkout_glob > $(git rev-parse --git-path info/sparse-checkout)
    $EDITOR $(git rev-parse --git-path info/sparse-checkout)

    echo "Reapplying sparse checkout..."
    git sparse-checkout reapply || { echo "Error reapplying sparse checkout!" >&2; return 1 }

    echo "Checking out worktree branch $worktree_base_branch..."
    git checkout $worktree_base_branch || { echo "Error checking out $worktree_base_branch!" >&2; return 1 }

    echo "Rebasing against $base_branch..."
    git rebase "origin/$base_branch" || { echo "Error rebasing against origin/$base_branch!" >&2; return 1 }

    echo "Running git status..."
    git status

    echo "Done! Please ensure that you regularly:"
    echo "  1. Fetch changes from remote (git fetch origin $base_branch)"
    echo "  2. Rebase the worktree's base branch against the fetched remote (git rebase origin/$base_branch)"
    echo "  3. Reapply sparse checkout to sync correctly (git sparse-checkout reapply)"
}

# Precmd hook to refresh aliases based on the current branch every time the prompt is shown
function precmd() {
    local branch_name="$(gbn)"

    if [[ -n $branch_name ]]; then
        # Set up new aliases
        alias gbcn="git branch --copy $branch_name"
        alias gbct="git branch --copy $branch_name _tmp_$branch_name"
        alias gbcz="git branch --copy $branch_name z/$branch_name"
        alias gbmn="git branch --move $branch_name"
        alias gbmt="git branch --move $branch_name _tmp/$branch_name"
        alias gbmz="git branch --move $branch_name z/$branch_name"
	    alias gwtA="git worktree add $HOME_GIT_WORKTREES/$(basename $(git rev-parse --show-toplevel))/$branch_name $branch_name"

        # Worktree check
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            local worktree=$(basename "$(git rev-parse --show-toplevel)")
            local worktree_target_branch="${branch_name}-${worktree}"
            if [[ $(git branch --list "$worktree_target_branch") && "$branch_name" != "$worktree_target_branch" ]]; then
                echo "Assuming $worktree_target instead of $branch_name"
                echo "Press ^C now to abort fetch and rebase..."

                echo "(1/5) Checking out $worktree_target_branch..."
                git checkout $worktree_target_branch || { echo "Error checking out $worktree_target_branch!" >&2; return 1 }

                echo "(2/5) Fetching origin $branch_name..."
                git fetch origin $branch_name || { echo "Error fetching origin $branch_name!" >&2; return 1 }

                echo "(3/5) Rebasing origin/$branch_name..."
                git rebase origin/$branch_name || { echo "Error rebasing origin/$branch_name!" >&2; return 1 }

                echo "(4/5) Reapplying sparse checkout..."
                git sparse-checkout reapply || { echo "Error reapplying sparse checkout!" >&2; return 1 }

                echo "(5/5) Checking out $worktree_target_branch..."
                git checkout $worktree_target_branch || { echo "Error checking out $worktree_target_branch!" >&2; return 1 }
            fi
        fi
    else
        unalias gbcn gbct gbcz gbmn gbmt gbmz gwta 2>/dev/null
    fi
}

# Returns the *l*ast *m*odified file
# E.g., tar xf $(lm); cd $(lm)' or cd LM if in caps
alias -g LF='./*(oc[1])'
function lm() {
    gls -Art $@ | tail -n1
}

# Notifications
function notify() {
    /usr/bin/osascript -e "display notification \"$*\""
}

# Architecture Changes
alias m1='arch -arm64'
alias intel='arch -x86_64'

# Make directories in sudo-only places and own
function mkdirown() {
    sudo mkdir -p $1 && sudo chown $USER $1
}

# Project
function mkproj() {
    mkdir -p $HOME_PROJECTS/$1/out
    mkdir -p $LLOG_DIR/$1
    ln -s $LLOG_DIR/$1 $HOME_PROJECTS/$1/log
}

# Undefines pre-existing aliases or functions for redefinition of work-related stuff
function undef() {
  local original_name="$1"
  local new_name="_$1"

  if typeset -f "$original_name" >/dev/null; then
    eval "$(typeset -f "$original_name" | sed "s/^$original_name/$new_name/")"
  elif alias "$original_name" >/dev/null 2>&1; then
    local alias_definition=$(alias "$original_name" | sed "s/^alias $original_name=//")
    eval "alias $new_name=$alias_definition"
    unalias "$original_name"
  fi
}

# Automatically venv activate
venva() {
    # Traverse upwards to find the closest "venv" or ".venv" directory
    local dir=$(pwd)
    while [[ $dir != "/" ]]; do
        if [[ -f "$dir/venv/bin/activate" ]]; then
            source "$dir/venv/bin/activate"
            return
        elif [[ -f "$dir/.venv/bin/activate" ]]; then
            source "$dir/.venv/bin/activate"
            return
        fi
        dir=$(dirname "$dir")
    done
    echo "No venv or .venv found in the directory tree."
    return 1
}
