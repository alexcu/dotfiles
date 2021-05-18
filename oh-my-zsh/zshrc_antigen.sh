source ~/.zshrc_custom              # Apply custom zshrc stuff
unset zle_bracketed_paste           # Allow drag and drop
unset MAILCHECK                     # Do not check mail
DISABLE_AUTO_TITLE="true"           # Disable auto-setting terminal title
COMPLETION_WAITING_DOTS="true"      # Display dots when waiting for completion
HOMEBREW_AUTO_UPDATE_SECS="604800"  # Only update weekly

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Antigen
source ~/.antigen/antigen.zsh
antigen use oh-my-zsh
antigen bundle git
antigen bundle osx
antigen bundle brew
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle z
antigen theme romkatv/powerlevel10k
antigen apply

# Apply p10k.zsh rules
source ~/.p10k.zsh
