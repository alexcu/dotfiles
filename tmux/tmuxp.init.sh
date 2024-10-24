#!/bin/bash

export DISABLE_AUTO_TITLE="true"
export PATH=/opt/homebrew/bin:$PATH

# Make alias paths avaliable
source ~/.zshrc.aliases.zsh

if [ -z "$TMUX" ]; then
    if ! /opt/homebrew/bin/tmux has-session -t scratch 2>/dev/null; then
        /opt/homebrew/bin/tmuxp load -d ~/.tmuxp/scratch.yaml
    fi

    if [ -f ~/.tmuxp.work/work.yaml ]; then
        if ! /opt/homebrew/bin/tmux has-session -t work 2>/dev/null; then
            /opt/homebrew/bin/tmuxp load -d ~/.tmuxp.work/work.yaml
        fi
    fi

    /opt/homebrew/bin/tmux attach -t scratch
fi
