#! /usr/bin/env zsh

#
# Python aliases
#

# Automatically venv activate
function venvc() {
    if [[ -d "./.venv" ]]; then
        echo "Virtual environment already exists at ./.venv"
        return 0
    fi
    python3 -m venv ./.venv
}

# Activate the virtual environment in the current directory
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

function mkvenv() {
    cecho cyan "🐍 Creating virtual environment..."
    venvc
    cecho cyan "🐍 Activating virtual environment..."
    venva
    cecho cyan "🐍 Done"
}
