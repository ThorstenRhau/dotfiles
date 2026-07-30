#!/bin/sh
#
# Sync token colorscheme contrib files into dotfiles.
# Run after 'make contrib' in the token repo.
#
# Usage: ./sync_token_themes.sh [TOKEN_REPO_PATH]
#   TOKEN_REPO_PATH defaults to ../token (sibling directory)

set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TOKEN_DIR="${1:-$(cd "$DOTFILES_DIR/.." && pwd)/token}"
CONTRIB="$TOKEN_DIR/contrib"

errors=0

err() {
  printf "ERROR: %s\n" "$1" >&2
  errors=$((errors + 1))
}

info() {
  printf "  %s\n" "$1"
}

require_file() {
  if [ ! -f "$1" ]; then
    err "missing source: $1"
    return 1
  fi
}

require_dir() {
  if [ ! -d "$1" ]; then
    err "missing directory: $1"
    return 1
  fi
}

copy_file() {
  src="$1"
  dst="$2"
  require_file "$src" || return 1
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  info "$dst"
}

# ------------------------------------------------------------------
# Preflight
# ------------------------------------------------------------------

if [ ! -d "$TOKEN_DIR" ]; then
  printf "ERROR: token repo not found at %s\n" "$TOKEN_DIR" >&2
  printf "Usage: %s [TOKEN_REPO_PATH]\n" "$0" >&2
  exit 1
fi

require_dir "$CONTRIB" || exit 1

required_sources='
bat/token-dark.tmTheme
bat/token-light.tmTheme
carapace/token-dark.json
carapace/token-light.json
delta/token.gitconfig
fzf/token-dark.zsh
fzf/token-light.zsh
ghostty/token-dark
ghostty/token-light
lazygit/token-dark.yml
lazygit/token-light.yml
ripgrep/token-dark.ripgreprc
ripgrep/token-light.ripgreprc
starship/token-dark.toml
starship/token-light.toml
tmux/token-dark.conf
tmux/token-light.conf
zsh/token-dark.zsh
zsh/token-light.zsh
'

for source in $required_sources; do
  if ! require_file "$CONTRIB/$source"; then
    :
  fi
done

if ! require_file "$DOTFILES_DIR/ripgrep/.config/ripgrep/config"; then
  :
fi

if [ "$errors" -gt 0 ]; then
  printf "Finished with %d error(s).\n" "$errors" >&2
  exit 1
fi

printf "Syncing token themes from %s\n" "$CONTRIB"
printf "Into dotfiles at %s\n\n" "$DOTFILES_DIR"

# ------------------------------------------------------------------
# Bat
# ------------------------------------------------------------------

printf "bat:\n"
copy_file "$CONTRIB/bat/token-dark.tmTheme" \
  "$DOTFILES_DIR/bat/.config/bat/themes/token-dark.tmTheme"
copy_file "$CONTRIB/bat/token-light.tmTheme" \
  "$DOTFILES_DIR/bat/.config/bat/themes/token-light.tmTheme"

# ------------------------------------------------------------------
# Carapace (completion styling)
# ------------------------------------------------------------------

printf "carapace:\n"
copy_file "$CONTRIB/carapace/token-dark.json" \
  "$DOTFILES_DIR/zsh/.config/zsh/themes/carapace-token-dark.json"
copy_file "$CONTRIB/carapace/token-light.json" \
  "$DOTFILES_DIR/zsh/.config/zsh/themes/carapace-token-light.json"

# ------------------------------------------------------------------
# Delta (git)
# ------------------------------------------------------------------

printf "delta:\n"
copy_file "$CONTRIB/delta/token.gitconfig" \
  "$DOTFILES_DIR/git/.config/git/delta_themes.inc"

# ------------------------------------------------------------------
# FZF (zsh variants)
# ------------------------------------------------------------------

printf "fzf (zsh):\n"
for variant in dark light; do
  copy_file "$CONTRIB/fzf/token-${variant}.zsh" \
    "$DOTFILES_DIR/fzf/.config/fzf/themes/token_${variant}.zsh"
done

# ------------------------------------------------------------------
# Zsh (syntax highlighting + completion theme)
# ------------------------------------------------------------------

printf "zsh:\n"
copy_file "$CONTRIB/zsh/token-dark.zsh" \
  "$DOTFILES_DIR/zsh/.config/zsh/themes/token-dark.zsh"
copy_file "$CONTRIB/zsh/token-light.zsh" \
  "$DOTFILES_DIR/zsh/.config/zsh/themes/token-light.zsh"

# ------------------------------------------------------------------
# Ghostty
# ------------------------------------------------------------------

printf "ghostty:\n"
copy_file "$CONTRIB/ghostty/token-dark" \
  "$DOTFILES_DIR/ghostty/.config/ghostty/themes/token-dark"
copy_file "$CONTRIB/ghostty/token-light" \
  "$DOTFILES_DIR/ghostty/.config/ghostty/themes/token-light"

# ------------------------------------------------------------------
# Lazygit
# ------------------------------------------------------------------

printf "lazygit:\n"
copy_file "$CONTRIB/lazygit/token-dark.yml" \
  "$DOTFILES_DIR/lazygit/.config/lazygit/token-dark.yml"
copy_file "$CONTRIB/lazygit/token-light.yml" \
  "$DOTFILES_DIR/lazygit/.config/lazygit/token-light.yml"

# ------------------------------------------------------------------
# Ripgrep (adapted: prepend base config, append token colors)
# ------------------------------------------------------------------

printf "ripgrep:\n"
rg_base="$DOTFILES_DIR/ripgrep/.config/ripgrep/config"
rg_base_lines=$(grep -v '^--color' "$rg_base")

for variant in dark light; do
  src="$CONTRIB/ripgrep/token-${variant}.ripgreprc"
  dst="$DOTFILES_DIR/ripgrep/.config/ripgrep/themes/token_${variant}"

  # Token contrib color lines (skip comment header)
  rg_colors=$(grep '^--' "$src")

  mkdir -p "$(dirname "$dst")"
  printf "%s\n%s\n" "$rg_base_lines" "$rg_colors" >"$dst"
  info "$dst"
done

# ------------------------------------------------------------------
# Starship (adapted: prepend palette = "token" directive)
# ------------------------------------------------------------------

printf "starship:\n"
for variant in dark light; do
  src="$CONTRIB/starship/token-${variant}.toml"
  dst="$DOTFILES_DIR/starship/.config/src/palette_${variant}.toml"
  if ! require_file "$src"; then
    continue
  fi

  # Token contrib has [palettes.token] section but no top-level palette directive.
  # The generate.sh script expects a palette = "..." line at the top.
  palette_section=$(sed -n '/^\[palettes\./,$p' "$src")
  if [ -z "$palette_section" ]; then
    err "no [palettes.*] section found in $src"
    continue
  fi

  mkdir -p "$(dirname "$dst")"
  printf 'palette = "token"\n\n%s\n' "$palette_section" >"$dst"
  info "$dst"
done

# Regenerate starship configs from source
sh "$DOTFILES_DIR/starship/.config/src/generate.sh"
info "starship configs regenerated"

# ------------------------------------------------------------------
# Tmux
# ------------------------------------------------------------------

printf "tmux:\n"
copy_file "$CONTRIB/tmux/token-dark.conf" \
  "$DOTFILES_DIR/tmux/.config/tmux/token-dark.conf"
copy_file "$CONTRIB/tmux/token-light.conf" \
  "$DOTFILES_DIR/tmux/.config/tmux/token-light.conf"

# ------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------

printf "\n"
if [ "$errors" -gt 0 ]; then
  printf "Finished with %d error(s).\n" "$errors" >&2
  exit 1
fi
printf "All token themes synced successfully.\n"
