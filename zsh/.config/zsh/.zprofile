# =============================================================================
# Homebrew (login shells only, subshells inherit via environment)
# =============================================================================

# macOS on Apple silicon, then Homebrew on Linux (WSL2 Ubuntu).
for _brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x "$_brew" ]] || continue
  eval "$("$_brew" shellenv)"
  # Apple silicon Homebrew only, as before Linux support.
  [[ "$_brew" == /opt/homebrew/* ]] && export ARCHFLAGS="-arch arm64"
  export HOMEBREW_AUTO_UPDATE_SECS=300
  export HOMEBREW_BAT=1
  export HOMEBREW_DOWNLOAD_CONCURRENCY=auto
  export HOMEBREW_EDITOR=nvim
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_ENV_HINTS=1
  export HOMEBREW_UPGRADE_GREEDY=1
  break
done
unset _brew

# =============================================================================
# PATH (after Homebrew so ~/bin takes precedence)
# =============================================================================

typeset -U path
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  /usr/local/bin
  # Ghostty CLI for shells outside Ghostty; (N) drops the entry when absent.
  /Applications/Ghostty.app/Contents/MacOS(N)
  $path
)
