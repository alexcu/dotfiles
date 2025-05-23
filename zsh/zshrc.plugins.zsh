#!/usr/bin/env zsh
DISABLE_UNTRACKED_FILES_DIRTY="true"

#
# Initiate Zsh completion system
#
autoload -Uz compinit
# Use the completion dump file if it exists, otherwise generate it
if [[ -f $ZSH_COMDUMP ]]; then
    compinit -C
else
    compinit -d $ZSH_COMDUMP
fi

#
# Source Custom Plugins
#
source $ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh

#
# Enabled zsh plugins
#

# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
plugins=(
    aliases             # als to show all plugin aliaes
    brew                # bcubc
    docker              # dps, dim, drmi etc. aliases
    command-not-found   # provides packages where command exists
    colorize            # colourises cat/less output
    colored-man-pages   # colourises man pages
    eza                 # replace ls with eza
    fzf                 # fuzzy finder
    fzf-tab             # fuzzy finder tab-complete
    fancy-ctrl-z        # press ctrl+z again to go back to suspended app
    gnu-utils           # working with gnu-utils
    git                 # gc, gcb, ga etc. aliases
    globalias           # expands aliases
    z                   # z <dir> to jump to directory
)

# Dot not expand the following aliases
GLOBALIAS_FILTER_VALUES=(1 l ls grep cat tmux tip z devloop dgcli)

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
# pasteinit() {
#   OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
#   zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
# }

# pastefinish() {
#   zle -N self-insert $OLD_SELF_INSERT
# }
# zstyle :bracketed-paste-magic paste-init pasteinit
# zstyle :bracketed-paste-magic paste-finish pastefinish

# Make height for fzf(-tab) the same
export FZF_HEIGHT_LINES=20
export FZF_DEFAULT_OPTS="
  --height ~$FZF_HEIGHT_LINES
  --walker-skip .git,node_modules,target
  --layout=reverse
  --bind 'alt-a:select-all,alt-d:deselect-all'
  --bind 'ctrl-space:toggle+down'
  --bind 'tab:down'
  --bind 'shift-tab:up'
"
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
"
zstyle ':fzf-tab:*' fzf-flags "--height=~$FZF_HEIGHT_LINES"

# Pretty preview and navigation of files
export FZF_PREVIEW="$HOME/.zshrc.plugins.fzf-preview.zsh"
zstyle ':completion:*' menu no

# Make tab the nested tab operator
zstyle ':fzf-tab:*' continuous-trigger 'enter'
zstyle ':fzf-tab:complete:*' fzf-preview '$FZF_PREVIEW $realpath'
zstyle ':fzf-tab:complete:files:*' fzf-preview 'eza -1 --icons --color=always $realpath'

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group '<' '>'

# Preview files when using fzf
 _fzf_comprun() {
   local command=$1
   shift

   case "$command" in
     cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
     export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
     ssh)          fzf --preview 'dig {}'                   "$@" ;;
     cat|bat)      fzf --preview 'bat -n --color=always {}' "$@" ;;
     *)            fzf --preview '$FZF_PREVIEW {}' "$@" ;;
   esac
 }

# Git should try and show diffs where possible
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'

# Hide .git
_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}
_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}

# Icons for eza always
zstyle ':omz:plugins:eza' 'icons' yes

# Use fd for listing path
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

#
# Brew-installed Zsh Plugins
#

# # Zsh Autosuggestions
# # https://github.com/zsh-users/zsh-autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# # Zsh Syntax Highlighting
# # https://github.com/zsh-users/zsh-syntax-highlighting
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Powerlevel10k Theme
# https://github.com/romkatv/powerlevel10k
source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
