#! /usr/bin/env zsh

#
# Python aliases
#

# Automatically venv activate
alias venvc="python3 -m venv ./.venv"
function venva() {
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
