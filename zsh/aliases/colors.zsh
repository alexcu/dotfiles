#!/usr/bin/env zsh

#
# Color aliases
#

# Colour echo (cecho red "foo")
function cecho() {
    local color=$1
    local bold=""
    local dim=""
    local text=""

    # Check if second argument is "bold" or "dim"
    if [[ "$2" == "bold" ]]; then
        bold="%B"
        text="${@:3}"
    elif [[ "$2" == "dim" ]]; then
        dim="%{$(tput dim)%}"
        text="${@:3}"
    else
        text="${@:2}"
    fi

    if [[ -n ${fg[$color]} ]]; then
        print -P "${bold}${dim}%F{$color}${text}%f%b%{$(tput sgr0)%}"
    elif [[ "$color" =~ ^[0-9]+$ ]] && [ "$color" -ge 0 ] && [ "$color" -le 255 ]; then
        print -P "${bold}${dim}\e[38;5;${color}m${text}\e[0m%b%{$(tput sgr0)%}"
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
