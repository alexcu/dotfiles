#!/bin/bash

# Ensure /opt/homebrew/bin is in the PATH
export PATH=/opt/homebrew/bin:$PATH

# Only proceed if we're not already inside a tmux session
if [ -z "$TMUX" ]; then
    # Ensure the scratch session exists (create it if it doesn't) without attaching
    if ! /opt/homebrew/bin/tmux has-session -t scratch 2>/dev/null; then
        /opt/homebrew/bin/tmuxp load -d /Users/alexcu/.tmuxp/scratch.yaml
    fi
    
    # Ensure the work session exists (create it if it doesn't) without attaching
    if ! /opt/homebrew/bin/tmux has-session -t work 2>/dev/null; then
        /opt/homebrew/bin/tmuxp load -d /Users/alexcu/.tmuxp/work.yaml
    fi
    
    # Finally, attach to the scratch session
    /opt/homebrew/bin/tmux attach -t scratch
fi
