# =============================================================================
# OS Detection (must be first, used by functions below)
# =============================================================================

export _OS_TYPE=$(uname)

# =============================================================================
# Environment Variables
# =============================================================================

export CXXFLAGS="-std=gnu++20"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export XDG_CONFIG_HOME="$HOME/.config"

# =============================================================================
# Secrets (may contain env vars needed by non-interactive scripts)
# =============================================================================

[[ -r "$ZDOTDIR/secrets.zsh" ]] && source "$ZDOTDIR/secrets.zsh"
