#! /usr/bin/env zsh

#
# Script aliases
#

# Prefix all executable scripts in $HOME_SCRIPTS with 'scr_'
if [[ -d "$HOME_SCRIPTS" ]]; then
    for script in "$HOME_SCRIPTS"/*(N); do
        [[ -f "$script" && -x "$script" ]] || continue
        filename="${script:t}"
        alias "scr_${filename}"="$script"
    done
fi
