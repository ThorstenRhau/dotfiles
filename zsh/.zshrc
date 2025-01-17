if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# Enable autocompletion
autoload -Uz compinit
compinit

# Basic autocompletion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' rehash true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Case-insensitive autocompletion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Show descriptions in the autocompletion menu
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format '%d'

# Expand variables and history in the autocompletion menu
zstyle ':completion:*' expand-variables true
zstyle ':completion:*' history-search true

# Autocomplete filenames with spaces
zstyle ':completion:*' filename-completion true

# Autocomplete directory names
zstyle ':completion:*' directory-completion true

# Highlight the matching part of the autocompletion suggestion
zstyle ':completion:*' highlight true

# Use a different character for the autocompletion menu
zstyle ':completion:*' list-separator '>'

# Set the height of the autocompletion menu
zstyle ':completion:*' menu-height 20

# Automatically select the first entry in the autocompletion menu
zstyle ':completion:*' select-first true

# Show hidden files in the autocompletion menu
zstyle ':completion:*' show-hidden true

# Use a different key for autocompletion
bindkey '^I' complete-word

# Use tab for autocompletion
bindkey '^I' complete-word

export ARCHFLAGS="-arch arm64"
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_NO_ANALYTICS=1
export MANPAGER="less"
export GREP_OPTIONS="--color=auto"
export EDITOR="nvim"
export LC_CTYPE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LSCOLORS=""
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

alias ls='ls -FG'
alias ssh='env TERM="xterm-256color" ssh'
alias python='python3'
alias pip='pip3'

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Define a function to use zoxide interactively
function zoxide_interactive() {
    result=$(zoxide query -i -- "$@")
    if [ $? -eq 0 ]; then
        cd "$result"
    fi
    zle reset-prompt
}

# Create a new ZLE widget from the function
zle -N zoxide_interactive

# Bind Ctrl+Z to the new widget
bindkey '^Z' zoxide_interactive

# Function to search command history with fzf
function fzf_history_search() {
    local selected_command
    selected_command=$(history -n 1 | fzf --tac --no-sort --query "$LBUFFER" +m --height 40% --layout=reverse)
    if [ -n "$selected_command" ]; then
        BUFFER=$selected_command
        CURSOR=$#BUFFER
    fi
    zle reset-prompt
}

# Create a new ZLE widget from the function
zle -N fzf_history_search

# Bind Ctrl+F to the new widget
bindkey '^R' fzf_history_search


if [ -f "$HOME/.zshrc_secrets" ]; then
    source "$HOME/.zshrc_secrets"
fi
