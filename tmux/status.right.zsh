#!/usr/bin/env zsh

GIT_CHECK_STALE_BASE_BRANCH_TIMEOUT=10800
GIT_CHECK_STALE_BASE_BRANCH_DEFAULT=("master" "main" "green")
GIT_CHECK_STALE_BASE_BRANCH_MESSAGE="Hast du heute schon \`git\` gemacht?"
GIT_STATUS_CACHE="/tmp/tmux_git_status_cache"
GIT_STATUS_CACHE_TIME="${GIT_STATUS_CACHE}_time"
CACHE_INTERVAL=30

CURRENT_TIME=$(date +%s)

# Tick function to display alternating characters for odd/even seconds
function tick() {
    (( CURRENT_TIME % 2 == 0 )) && echo -n "${2:- }" || echo -n "${1}"
}

# Status function for consistent formatting of output
function status() {
    echo -n "$1 #[default]"
}

# Status for displaying the current path
function status_pwd() {
    status "#[dim fg=white]$1"
}

# Function to check if a specific branch is stale
function check_stale_branch() {
    local branch="$1"
    local repo_path="$2"
    local max_time="$3"

    local last_commit_time=$(git -C "$repo_path" log -1 --format=%ct "$branch" 2>/dev/null)
    if [ -n "$last_commit_time" ]; then
        local time_diff=$((CURRENT_TIME - last_commit_time))
        if [ "$time_diff" -gt "$max_time" ]; then
            status "#[fg=white bg=red] $GIT_CHECK_STALE_BASE_BRANCH_MESSAGE #[dim]($branch)"
            return 0
        fi
    fi
    return 1
}

function update_git_status_cache() {
    local repo_path="$1"
    local max_time="$2"
    local branches=("${GIT_CHECK_STALE_BASE_BRANCH_DEFAULT[@]}")

    # Check if inside a git repo
    if ! git -C "$repo_path" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return
    fi

    # Initialize output
    local output=""

    # Get current branch
    local current_branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)
    if [[ " ${branches[@]} " =~ " ${current_branch} " ]]; then
        output=$(check_stale_branch "$current_branch" "$repo_path" "$max_time")
    else
        # Loop through default branches
        for branch in "${branches[@]}"; do
            output=$(check_stale_branch "$branch" "$repo_path" "$max_time")
            if [[ -n "$output" ]]; then
                break
            fi
        done
    fi

    # Save to cache
    echo "$output" > "$GIT_STATUS_CACHE"
    date +%s > "$GIT_STATUS_CACHE_TIME"
}

# Wrapper function to check cache and return result
function status_git() {
    local repo_path="$1"
    local max_time="${2:-$GIT_CHECK_STALE_BASE_BRANCH_TIMEOUT}"

    local current_time=$(date +%s)
    local last_cache_time=$(cat "$GIT_STATUS_CACHE_TIME" 2>/dev/null || echo 0)

    if (( current_time - last_cache_time > CACHE_INTERVAL )); then
        update_git_status_cache "$repo_path" "$max_time"
    fi

    # Output cached status
    cat "$GIT_STATUS_CACHE"
}

# Status for displaying the current time
function status_time() {
    local date_time=$(date "+%Y-%m-%d %H$(tick ':')%M$(tick ':')%S")
    status "#[fg=white bg=blue] $date_time"
}

# Status for displaying the tmux session information
function status_session() {
    local session_info=$(tmux display-message -p '#[bg=yellow] [ #[dim]#{session_id} #[default bg=yellow]#{session_name} ]')
    status "$session_info"
}

function generate_status_bar() {
    local pane_current_path="$1"

    # Retrieve each output, some may be cached
    local output_pwd=$(status_pwd "$pane_current_path")
    #local output_git=$(status_git "$pane_current_path")
    local output_time=$(status_time)
    local output_session=$(status_session)

    # Output the combined results
    echo "$output_pwd$output_git$output_time$output_session"
}

generate_status_bar "$@"
