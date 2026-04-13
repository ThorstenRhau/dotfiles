# =============================================================================
# History
# =============================================================================

HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY HIST_REDUCE_BLANKS

# =============================================================================
# Completion
# =============================================================================

# Additional completions from Homebrew
if [[ -d /opt/homebrew/share/zsh-completions ]]; then
    fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi

# Autoloaded functions
fpath=("$ZDOTDIR/functions" $fpath)
autoload -Uz "$ZDOTDIR/functions"/*(.:t)

autoload -Uz compinit
if [[ -n $ZDOTDIR/.zcompdump(#qN.mh-1) ]]; then
    compinit -C -d "$ZDOTDIR/.zcompdump"
else
    compinit -d "$ZDOTDIR/.zcompdump"
fi

[[ -d "$ZDOTDIR/.zcompcache" ]] || mkdir -p "$ZDOTDIR/.zcompcache"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZDOTDIR/.zcompcache"

# =============================================================================
# Key Bindings
# =============================================================================

bindkey -e
bindkey '^[[Z' reverse-menu-complete

# =============================================================================
# Editor
# =============================================================================

if (( $+commands[nvim] )); then
    export EDITOR=nvim
    export VISUAL="$EDITOR"
    export SUDO_EDITOR="$EDITOR"
    export MANPAGER="nvim +Man! -"
    export MANCOLOR=true
    alias nv=nvim
fi

# =============================================================================
# Aliases
# =============================================================================

export LSCOLORS="Exfxcxdxbxegedabagacad"
alias ls='ls -G'
(( $+commands[bat] ))     && alias cat=bat
(( $+commands[lazygit] )) && alias lg=lazygit
(( $+commands[pip3] ))    && alias pip=pip3
(( $+commands[python3] )) && alias python=python3

# Git
alias gc='git commit'
alias gca='git commit -a'
alias gd='git diff'
alias gl='git pull'
alias glg='git log --oneline --graph --decorate -n 20'
alias gp='git push'
alias gpristine='git reset --hard && git clean --force -dfx'
alias gst='git status'

# =============================================================================
# Appearance & Theming
# =============================================================================

# Query actual system appearance instead of inheriting from parent shell
if [[ "$_OS_TYPE" == "Darwin" ]]; then
    if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
        export SYSTEM_APPEARANCE=dark
    else
        export SYSTEM_APPEARANCE=light
    fi
else
    export SYSTEM_APPEARANCE="${SYSTEM_APPEARANCE:-dark}"
fi

typeset -gi _appearance_prompt_count=2

autoload -Uz add-zsh-hook
add-zsh-hook precmd _check_appearance

# =============================================================================
# Zoxide
# =============================================================================

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh --cmd cd)"

    function _zoxide_zi_widget() {
        local result
        result="$(zoxide query -i)" && cd "$result"
        zle reset-prompt
    }
    zle -N _zoxide_zi_widget
    bindkey '\ez' _zoxide_zi_widget
fi

# =============================================================================
# Carapace
# =============================================================================

if (( $+commands[carapace] )); then
    export CARAPACE_BRIDGES='bash,zsh,fish,inshellisense,cobra'
    source <(carapace _carapace)
fi

# =============================================================================
# FZF
# =============================================================================

if (( $+commands[fzf] )); then
    source <(fzf --zsh)

    # Base options (layout, behavior) preserved across theme changes
    export _FZF_BASE_OPTS="\
--height=40% --layout=reverse --info=inline --cycle \
--border=sharp --scrollbar='│' \
--prompt='❯ ' --pointer='▶' --marker='✓' \
--ghost='Type to search...' \
--bind='ctrl-/:toggle-preview'"

    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND='fd --type f --hidden --exclude .git'

    # Ctrl-T: file finder with bat preview
    local preview_cmd="cat {}"
    (( $+commands[bat] )) && preview_cmd="bat --color=always --line-range :500 {}"
    export FZF_CTRL_T_OPTS="\
--scheme=path --multi \
--preview '$preview_cmd' \
--preview-window='right:60%:wrap' \
--preview-label=' Preview ' \
--header='ctrl-/ preview, ctrl-a all, ctrl-d none' \
--bind='ctrl-a:select-all,ctrl-d:deselect-all' \
--bind='alt-h:change-preview-window(hidden|right:60%:wrap)'"

    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

    # Alt-C: directory finder with tree preview
    local tree_cmd="tree -C -L 2 {}"
    export FZF_ALT_C_OPTS="\
--scheme=path \
--preview '$tree_cmd' \
--preview-window='right:50%' \
--preview-label=' Directory ' \
--header='ctrl-/ toggle preview'"

    # Ctrl-R: history search
    export FZF_CTRL_R_OPTS="\
--scheme=history --with-nth=2.. \
--header='shift-del: delete | ctrl-y: copy' \
--bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' \
--bind='shift-delete:execute-silent(perl $HOME/.config/zsh/scripts/fzf-history-delete $HOME/.config/zsh/.zsh_history {2..})+down'"
fi

# =============================================================================
# Apply Theme (after FZF base opts are defined)
# =============================================================================

_apply_appearance

# =============================================================================
# Ghostty Shell Integration
# =============================================================================

if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
    local ghostty_integration="$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
    [[ -r "$ghostty_integration" ]] && source "$ghostty_integration"
fi

# =============================================================================
# Starship
# =============================================================================

if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi

# =============================================================================
# Plugins
# =============================================================================

# Autosuggestions (fish-like ghost text)
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
local _plugin_dir="/opt/homebrew/share"
[[ -r "$_plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$_plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Fast syntax highlighting (must be sourced last among plugins)
local _fsh="/opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
[[ -r "$_fsh" ]] && source "$_fsh"

# =============================================================================
# Local Configuration
# =============================================================================

[[ -r "$ZDOTDIR/local.zsh" ]] && source "$ZDOTDIR/local.zsh"
