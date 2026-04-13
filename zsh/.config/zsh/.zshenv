# =============================================================================
# OS Detection (must be first, used by functions below)
# =============================================================================

export _OS_TYPE=$(uname)

# =============================================================================
# Homebrew
# =============================================================================

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"

    export ARCHFLAGS="-arch arm64"
    export HOMEBREW_BAT=1
    export HOMEBREW_DOWNLOAD_CONCURRENCY=auto
    export HOMEBREW_EDITOR=nvim
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_UPGRADE_GREEDY=1
fi

# =============================================================================
# Environment Variables
# =============================================================================

export CXXFLAGS="-std=gnu++20"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export XDG_CONFIG_HOME="$HOME/.config"

# =============================================================================
# PATH
# =============================================================================

typeset -U path
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.cache/lm-studio/bin"
    "$HOME/.rd/bin"
    "$HOME/.docker/bin"
    "$HOME/.opencode/bin"
    /usr/local/bin
    $path
)

# =============================================================================
# Secrets (may contain env vars needed by non-interactive scripts)
# =============================================================================

[[ -r "$ZDOTDIR/secrets.zsh" ]] && source "$ZDOTDIR/secrets.zsh"
