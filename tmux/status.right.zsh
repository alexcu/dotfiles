#!/usr/bin/env zsh

export GIT_CHECK_STALE_BASE_BRANCH_TIMEOUT=3600
export GIT_CHECK_STALE_BASE_BRANCH_DEFAULT=("master" "main" "green")
export GIT_CHECK_STALE_BASE_BRANCH_MESSAGE="Hast du heute schon \`git\` gemacht?"

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
            status "#[fg=white bg=red] [$(tick '!')] $GIT_CHECK_STALE_BASE_BRANCH_MESSAGE #[dim]($branch)"
            return 0
        fi
    fi
    return 1
}

# Git status function with staleness check for the current branch first, then others
function status_git() {
    local repo_path=${1:-$(pwd)}
    local max_time=${2:-"$GIT_CHECK_STALE_BASE_BRANCH_TIMEOUT"}
    local branches=("${GIT_CHECK_STALE_BASE_BRANCH_DEFAULT[@]}")

    local output=""

    if ! git -C "$repo_path" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 1
    fi

    local current_branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)
    if [[ " ${branches[@]} " =~ " ${current_branch} " ]]; then
        output=$(check_stale_branch "$current_branch" "$repo_path" "$max_time")
        if [[ -n "$output" ]]; then
            echo "$output"
            return 0
        fi
    fi

    # Loop through all default branches if not current
    for branch in "${branches[@]}"; do
        output=$(check_stale_branch "$branch" "$repo_path" "$max_time")
        if [[ -n "$output" ]]; then
            echo "$output"
            return 0
        fi
    done

    return 0
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

# Main function to generate the status bar in parallel
function generate_status_bar() {
    local pane_current_path="$1"

    # Capture output from each status function in the background
    local output_pwd=$(status_pwd "$pane_current_path" &)
    local output_git=$(status_git "$pane_current_path" &)
    local output_time=$(status_time &)
    local output_session=$(status_session &)

    # Wait for all background processes to finish
    wait

    # Output the combined results
    echo "$output_pwd$output_git$output_time$output_session"
}

generate_status_bar "$@"
