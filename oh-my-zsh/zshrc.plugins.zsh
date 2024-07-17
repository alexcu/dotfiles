#!/usr/bin/env zsh

# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
plugins=(
    1password           # opwd command
    aliases             # als to show all plugin aliaes
    bazel               # bzb (build), bzt (test) etc.
    brew                # bcubc
    docker              # dps, dim, drmi etc. aliases
    docker-compose      # dc
    command-not-found   # provides packages where command exists
    colorize            # colourises cat/less output
    colored-man-pages   # colourises man pages
    fancy-ctrl-z        # press ctrl+z again to go back to suspended app
    gnu-utils           # working with gnu-utils
    git                 # gc, gcb, ga etc. aliases
    globalias           # expands aliases
    macos               # ofd, tab, music etc. aliases
    screen              # screen status
    z                   # z command
)

# Dot not expand the following aliases
GLOBALIAS_FILTER_VALUES=(l ls grep cat)
