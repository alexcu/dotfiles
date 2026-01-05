#! /usr/bin/env zsh

#
# Time aliases
#

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

# Datestamp prefix with user and date (short)
alias dscp="$USER-$(date +%Y%m%d)-"

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

# Colored timestamp
function cts() {
    ts "$(cred)$LOGGING_TIMESTAMP_FORMAT$(creset)"
}
