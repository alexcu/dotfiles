#! /usr/bin/env zsh

#
# Projects aliases
#

# Make project in $HOME_PROJECTS and $LLOG_DIR
function mkproj() {
    mkdir -p $HOME_PROJECTS/$1/out
    mkdir -p $LLOG_DIR/$1
    ln -s $LLOG_DIR/$1 $HOME_PROJECTS/$1/log
}
