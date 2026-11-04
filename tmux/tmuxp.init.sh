#!/bin/bash

export DISABLE_AUTO_TITLE="true"
export PATH=/opt/homebrew/bin:$PATH

# Make alias paths avaliable
source $HOME/.zshrc.aliases.zsh > /dev/null 2>&1

if [ -z "$TMUX" ]; then
    if ! /opt/homebrew/bin/tmux has-session -t scratch 2>/dev/null; then
        /opt/homebrew/bin/tmuxp load -d ~/.tmuxp/scratch.yaml
    fi

    if [ -f ~/.tmuxp.work/work.yaml ]; then
        if ! /opt/homebrew/bin/tmux has-session -t canva 2>/dev/null; then
            /opt/homebrew/bin/tmuxp load -d ~/.tmuxp.work/work.yaml
        fi
    fi

    if ! /opt/homebrew/bin/tmux has-session -t agents 2>/dev/null; then
        /opt/homebrew/bin/tmuxp load -d ~/.tmuxp/agents.yaml
    fi

    /opt/homebrew/bin/tmux attach -t scratch
fi
