#! /usr/bin/env zsh

#
# Script aliases
#

# Prefix all executable scripts in $HOME_SCRIPTS with 'scr_'
for script in $HOME_SCRIPTS/*; do
    if [[ -f $script && -x $script ]]; then
        filename=$(basename "$script")
        alias "scr_$filename"="$script"
    fi
done
