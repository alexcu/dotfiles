# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.zshrc.custom.zsh          # Apply custom zshrc stuff

unset zle_bracketed_paste           # Allow drag and drop
unset MAILCHECK                     # Do not check mail
DISABLE_AUTO_TITLE="true"           # Disable auto-setting terminal title
COMPLETION_WAITING_DOTS="true"      # Display dots when waiting for completion
HOMEBREW_AUTO_UPDATE_SECS="604800"  # Only update weekly

# Antigen
source ~/.antigen/antigen.zsh

# Apply Docker incl. antigen plugins
source ~/.zshrc.docker.zsh

# Antigen plugins
antigen use oh-my-zsh
antigen bundle git
antigen bundle aws
antigen bundle osx
antigen bundle brew
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle z
antigen theme romkatv/powerlevel10k
antigen apply

# Apply p10k.zsh rules
source ~/.p10k.zsh

# REA stuff
#. "$HOME/.rea-cli/rea-shell-init.sh"
#export AWS_DEFAULT_REGION=ap-southeast-2
#export AWS_REGION=ap-southeast-2
#export OKTA_PUSH=1

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
