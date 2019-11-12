source ~/.antigen/antigen.zsh

# Allow drag and drop
unset zle_bracketed_paste
# Don't tell me 'you have mail'
MAILCHECK=0
# Disable auto-setting terminal title
DISABLE_AUTO_TITLE="true"
# Display red dots whilst waiting for completion
COMPLETION_WAITING_DOTS="true"

# Load the oh-my-zsh's library
antigen use oh-my-zsh

# Bundles
antigen bundles <<EOBUNDLES
  git
  osx
  brew
  zsh-users/zsh-syntax-highlighting
  z
EOBUNDLES

# Theme
antigen theme sorin

# Custom
source ~/.zshrc_custom

# Done
antigen apply
export PATH="/Users/Alex/.splashkit:$PATH"
export PATH="/Users/Alex/.splashkit:$PATH"
