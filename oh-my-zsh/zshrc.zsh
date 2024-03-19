# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Pre-zshrc run
source ~/.zshrc.top.zsh

# Zsh Plugins and Load
source ~/.zshrc.plugins.zsh
export ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Custom Zsh Configs
source ~/.zshrc.aliases.zsh
source ~/.zshrc.custom.zsh
source ~/.zshrc.docker.zsh
source ~/.zshrc.canva.zsh

# Post-zshrc run
source ~/.zshrc.end.zsh
