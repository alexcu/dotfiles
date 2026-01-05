#! /usr/bin/env zsh

#
# Logging aliases
#

# LLogging directory
export LLOG_DIR="$HOME_LLOG"

# Log output to LLogging directory
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

# List LLogging directory with lm
function lmlog() {
    lm $LLOG_DIR/$@/**/*.log
}

# Show LLogging directory with bat
function slog() {
    bat $(lmlog $1) -l log
}

# Tail LLogging directory
function tlog() {
    tail -f $(lmlog $1) | bat --paging=never --style=plain -l log
}
