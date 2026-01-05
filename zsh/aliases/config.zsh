#! /usr/bin/env zsh

#
# Config zsh aliases
#

_cfg_zsh() {
    echo Unlocking .zshrc for edits...
    sudo chflags nouchg ~/.zshrc
    $EDITOR $HOME/.zshrc
    echo Locking down .zshrc for edits...
    sudo chflags uchg ~/.zshrc
}
alias cfg_zsh="_cfg_zsh"
alias cfg_dot="code $HOME_DOTFILES"
alias cfg_emacs="$EDITOR $HOME/.emacs"
alias cfg_tmux="$EDITOR $HOME/.tmux.conf"
alias cfg_als="$EDITOR $HOME/.zshrc.aliases.zsh"
alias cfg_scr="code $HOME_SCRIPTS"
