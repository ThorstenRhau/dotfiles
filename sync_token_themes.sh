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
  if [ ! -s "$1" ]; then
    err "empty source: $1"
    return 1
  fi
}

require_dir() {
  if [ ! -d "$1" ]; then
    err "missing directory: $1"
    return 1
  fi
}

require_line() {
  if ! grep -q "$2" "$1"; then
    err "$3 $1"
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

# Print "key=#rrggbb" for every palette key in the [palettes.NAME] section.
# Report each missing or malformed key and fail if any.
palette_vars() {
  awk -v section="[palettes.$2]" -v keys="$palette_keys" -v file="$1" '
    BEGIN { count = split(keys, wanted, " ") }
    /^\[/ { in_section = ($0 == section); next }
    in_section && NF == 3 && $2 == "=" && $3 ~ /^"#[0-9A-Fa-f]{6}"$/ {
      value[$1] = substr($3, 2, 7)
    }
    END {
      for (i = 1; i <= count; i++) {
        key = wanted[i]
        if (key in value) {
          print key "=" value[key]
        } else {
          printf "ERROR: palette key %s missing or invalid in %s\n", key, file > "/dev/stderr"
          failed = 1
        }
      }
      exit failed
    }
  ' "$1"
}

# Run "$1 SOURCE DESTINATION" for every Token file copied unchanged.
# SOURCE is relative to $CONTRIB and DESTINATION to $DOTFILES_DIR.
for_each_copy() {
  action="$1"
  for appearance in $appearances; do
    "$action" "herdr/$appearance.toml" \
      "herdr/.config/herdr/themes/$appearance.toml"
    for mode in $modes; do
      theme="$appearance-$mode"
      "$action" "bat/$theme.tmTheme" "bat/.config/bat/themes/$theme.tmTheme"
      "$action" "carapace/$theme.json" \
        "zsh/.config/zsh/themes/carapace-$theme.json"
      "$action" "fzf/$theme.zsh" "fzf/.config/fzf/themes/$theme.zsh"
      "$action" "zsh/$theme.zsh" "zsh/.config/zsh/themes/$theme.zsh"
      "$action" "ghostty/$theme" "ghostty/.config/ghostty/themes/$theme"
      "$action" "lazygit/$theme.yml" "lazygit/.config/lazygit/$theme.yml"
      "$action" "tmux/$theme.conf" "tmux/.config/tmux/$theme.conf"
    done
  done
}

check_copy() {
  require_file "$CONTRIB/$1" || :
}

sync_copy() {
  copy_file "$CONTRIB/$1" "$DOTFILES_DIR/$2"
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

appearances='token token-flint token-temper token-ultra token-meridian'
modes='dark light'
palette_keys='fg muted subtle accent blue green red yellow purple cyan orange'

for_each_copy check_copy

for appearance in $appearances; do
  delta_src="$CONTRIB/delta/$appearance.gitconfig"
  if require_file "$delta_src"; then
    require_line "$delta_src" '^\[delta ' "no [delta ...] section found in" || :
  fi

  for mode in $modes; do
    rg_src="$CONTRIB/ripgrep/$appearance-$mode.ripgreprc"
    if require_file "$rg_src"; then
      require_line "$rg_src" '^--' "no color options found in" || :
    fi

    starship_src="$CONTRIB/starship/$appearance-$mode.toml"
    if require_file "$starship_src"; then
      require_line "$starship_src" "^\[palettes\.$appearance\]\$" \
        "no [palettes.$appearance] section found in" || :
      palette_vars "$starship_src" "$appearance" >/dev/null ||
        errors=$((errors + 1))
    fi
  done
done

rg_base="$DOTFILES_DIR/ripgrep/.config/ripgrep/config"
if require_file "$rg_base"; then
  if ! grep -v '^--color' "$rg_base" | grep -q '^-'; then
    err "no non-color options found in $rg_base"
  fi
fi

# generate.sh runs mid-sync, so check its inputs before writing anything.
require_file "$DOTFILES_DIR/starship/.config/src/generate.sh" || :
require_file "$DOTFILES_DIR/starship/.config/src/base.toml" || :

if [ "$errors" -gt 0 ]; then
  printf "Finished with %d error(s).\n" "$errors" >&2
  exit 1
fi

printf "Syncing token themes from %s\n" "$CONTRIB"
printf "Into dotfiles at %s\n\n" "$DOTFILES_DIR"

# ------------------------------------------------------------------
# Unchanged copies (herdr, bat, carapace, fzf, zsh, ghostty, lazygit, tmux)
# ------------------------------------------------------------------

printf "copies:\n"
for_each_copy sync_copy

# ------------------------------------------------------------------
# Delta (git)
# ------------------------------------------------------------------

printf "delta:\n"
delta_dst="$DOTFILES_DIR/git/.config/git/delta_themes.inc"
# Build in memory so a failed read cannot leave a partial include behind.
delta_content=$(
  printf '%s\n\n' '# Generated by token colorscheme. Do not edit manually.'
  first_delta=1
  for appearance in $appearances; do
    if [ "$first_delta" -eq 0 ]; then
      printf '\n'
    fi
    sed -n '/^\[delta /,$p' "$CONTRIB/delta/$appearance.gitconfig"
    first_delta=0
  done
)
mkdir -p "$(dirname "$delta_dst")"
printf '%s\n' "$delta_content" >"$delta_dst"
info "$delta_dst"

# ------------------------------------------------------------------
# Git (adapted from the Token Starship palette)
# ------------------------------------------------------------------

printf "git:\n"
for appearance in $appearances; do
  for mode in $modes; do
    src="$CONTRIB/starship/$appearance-$mode.toml"
    dst="$DOTFILES_DIR/git/.config/git/$appearance-$mode.gitconfig"

    # Sets fg, muted, accent and the other palette keys. eval is safe here:
    # palette_vars only prints fixed key names with #rrggbb values.
    palette=$(palette_vars "$src" "$appearance")
    eval "$palette"

    mkdir -p "$(dirname "$dst")"
    # shellcheck disable=SC2154 # The palette variables come from eval above.
    cat >"$dst" <<EOF
# Generated from the $appearance $mode palette. Do not edit manually.

[color "advice"]
	hint = "$cyan"

[color "blame"]
	repeatedLines = "$subtle"

[color "branch"]
	current = "bold $accent"
	local = "bold $blue"
	plain = "$fg"
	remote = "bold $cyan"
	upstream = "bold $cyan"
	worktree = "bold $purple"

[color "decorate"]
	HEAD = "bold $accent"
	branch = "bold $green"
	grafted = "$muted"
	remoteBranch = "bold $cyan"
	stash = "$purple"
	tag = "bold $orange"

[color "diff"]
	# Keep glg's commit colour, but let delta style diff bodies.
	commit = "$blue"

[color "grep"]
	column = "$cyan"
	context = "$muted"
	filename = "bold $blue"
	function = "$purple"
	lineNumber = "$yellow"
	match = "bold $accent"
	matchContext = "bold $accent"
	matchSelected = "bold $accent"
	selected = "$fg"
	separator = "$subtle"

[color "interactive"]
	error = "bold $red"
	header = "bold $purple"
	help = "$muted"
	plain = "$fg"
	prompt = "bold $accent"

[color "push"]
	error = "bold $red"

[color "remote"]
	error = "bold $red"
	hint = "$cyan"
	success = "$green"
	warning = "$yellow"

[color "status"]
	added = "$green"
	branch = "bold $accent"
	changed = "bold $yellow"
	header = "$muted"
	localBranch = "$blue"
	noBranch = "bold $red"
	remoteBranch = "$cyan"
	unmerged = "bold $red"
	untracked = "$cyan"
	updated = "$green"

[color "transport"]
	rejected = "bold $red"
EOF
    info "$dst"
  done
done

# ------------------------------------------------------------------
# Ripgrep (adapted: prepend base config, append token colors)
# ------------------------------------------------------------------

printf "ripgrep:\n"
rg_base_lines=$(grep -v '^--color' "$rg_base")

for appearance in $appearances; do
  for mode in $modes; do
    src="$CONTRIB/ripgrep/$appearance-$mode.ripgreprc"
    dst="$DOTFILES_DIR/ripgrep/.config/ripgrep/themes/$appearance-$mode"

    # Token contrib color lines (skip comment header)
    rg_colors=$(grep '^--' "$src")

    mkdir -p "$(dirname "$dst")"
    printf "%s\n%s\n" "$rg_base_lines" "$rg_colors" >"$dst"
    info "$dst"
  done
done

# ------------------------------------------------------------------
# Starship (adapted: prepend the selected palette directive)
# ------------------------------------------------------------------

printf "starship:\n"
for appearance in $appearances; do
  for mode in $modes; do
    src="$CONTRIB/starship/$appearance-$mode.toml"
    dst="$DOTFILES_DIR/starship/.config/src/palettes/$appearance-$mode.toml"

    # Token contrib has a palette section but no top-level palette directive.
    palette_section=$(sed -n "/^\[palettes\.$appearance\]\$/,\$p" "$src")

    mkdir -p "$(dirname "$dst")"
    printf 'palette = "%s"\n\n%s\n' "$appearance" "$palette_section" >"$dst"
    info "$dst"
  done
done

# Regenerate starship configs from source
sh "$DOTFILES_DIR/starship/.config/src/generate.sh"
info "starship configs regenerated"

printf "\nAll token themes synced successfully.\n"
