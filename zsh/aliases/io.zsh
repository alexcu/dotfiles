#! /usr/bin/env zsh

#
# CLI I/O aliases
#

# Confirm for user input (enter or y/n)
function confirm() {
    local prompt="${1:-Press Enter to continue...}"
    local mode="${2:-}"  # Pass "--yn" to enable yes/no mode

    if [[ "$mode" == "--yn" ]]; then
        echo -n "${prompt} [y/N] "
        read -s -k 1 reply
        echo
        case "$reply" in
        [yY]) return 0 ;;
        *)    return 1 ;;
        esac
    else
        echo -n "$prompt"
        read -s -k 1
        echo
        return 0
    fi
}

# Notifications
function notify() {
    message=$1
    icon=$3
    title="${icon:+$icon }$2"
    sound=$4
    /usr/bin/osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
}
