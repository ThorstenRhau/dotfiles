# =============================================================================
# Homebrew (login shells only, subshells inherit via environment)
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
# PATH (after Homebrew so ~/bin takes precedence)
# =============================================================================

typeset -U path
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  /usr/local/bin
  $path
)
