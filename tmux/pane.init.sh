#!/bin/bash
# ~/.tmux.pane.init
# Usage: ~/.tmux.pane.init "<session_name>:<window_name>.<pane_index>" "pane-title"
# If <session_name>:<window_name>.<pane_index> is not provided, it defaults to the active pane.
# If the pane title is empty (""), the pane title will not default to the target.

target="$1"
pane_title="$2"

# Debug information to help trace what's happening
echo "Target: $target"
echo "Pane title: $pane_title"

# If the target is empty, default to the active pane
if [ -z "$target" ]; then
    # Default to the active pane
    target=$(tmux display -p '#S:#I.#P')
    echo "No target provided. Using active pane: $target"
fi

# If the pane title is not provided, set it to an empty string
if [ -z "$pane_title" ]; then
    pane_title=""
    echo "No pane title provided, setting to empty string."
fi

# Run tmux select-pane with the correct arguments
echo "Executing: tmux select-pane -t \"$target\" -T \"$pane_title\""
tmux select-pane -t "$target" -T "$pane_title"
