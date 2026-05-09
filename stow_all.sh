#!/bin/sh

set -eu

# This script links all dot files with the GNU stow command

if ! command -v stow >/dev/null; then
  echo "Error: 'stow' command not found. Please install it to continue."
  exit 1
fi

DOTFILES_DIR=$(
  unset CDPATH
  cd "$(dirname "$0")" && pwd
)
cd "$DOTFILES_DIR"

ensure_private_dir() {
  mkdir -p "$1"
  chmod 700 "$1"
}

copy_private_file() {
  src="$1"
  dst="$2"

  [ -f "$src" ] || return 0
  mkdir -p "$(dirname "$dst")"
  cp -p "$src" "$dst"
  chmod go-rwx "$dst"
}

unfold_config_dir() {
  target_dir="$1"
  expected_source="$2"
  shift 2

  [ -L "$target_dir" ] || return 0

  link_target=$(
    unset CDPATH
    cd "$target_dir" 2>/dev/null && pwd -P
  ) || link_target=
  expected_target=$(
    unset CDPATH
    cd "$expected_source" 2>/dev/null && pwd -P
  ) || expected_target=

  if [ -n "$link_target" ] && [ "$link_target" = "$expected_target" ]; then
    tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-local.XXXXXX")
    for private_file do
      copy_private_file "$target_dir/$private_file" "$tmp_dir/$private_file"
    done
    rm -f "$target_dir"
    mkdir -p "$target_dir"
    for private_file do
      copy_private_file "$tmp_dir/$private_file" "$target_dir/$private_file"
    done
    rm -rf "$tmp_dir"
    echo "Unfolded $target_dir so local files stay outside the repo"
  fi
}

migrate_local_file() {
  old_file="$1"
  new_file="$2"

  [ -f "$old_file" ] || return 0

  if [ -L "$new_file" ]; then
    rm -f "$new_file"
  fi

  if [ ! -e "$new_file" ]; then
    copy_private_file "$old_file" "$new_file"
    echo "Migrated $(basename "$old_file") to $new_file"
  elif ! cmp -s "$old_file" "$new_file"; then
    backup="$new_file.$(date +%Y%m%d%H%M%S).repo-backup"
    copy_private_file "$old_file" "$backup"
    echo "Preserved differing repo-local $(basename "$old_file") at $backup"
  fi

  rm -f "$old_file"
}

migrate_runtime_state() {
  zsh_config_dir="$DOTFILES_DIR/zsh/.config/zsh"
  fish_config_dir="$DOTFILES_DIR/fish/.config/fish"
  zsh_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
  zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  old_history="$zsh_config_dir/.zsh_history"
  new_history="$zsh_state_dir/.zsh_history"

  ensure_private_dir "$zsh_state_dir"
  ensure_private_dir "$zsh_cache_dir"

  if [ -f "$old_history" ]; then
    if [ -s "$old_history" ]; then
      if [ -s "$new_history" ]; then
        if ! cmp -s "$old_history" "$new_history"; then
          cat "$old_history" >>"$new_history"
          echo "Migrated old zsh history into $new_history"
        fi
      else
        cp "$old_history" "$new_history"
        echo "Migrated old zsh history to $new_history"
      fi
      chmod 600 "$new_history"
    fi
    rm -f "$old_history"
    echo "Removed old repo-local zsh history"
  fi

  if [ -f "$zsh_config_dir/.zcompdump" ]; then
    rm -f "$zsh_config_dir/.zcompdump"
    echo "Removed old repo-local zsh compdump"
  fi

  if [ -d "$zsh_config_dir/.zcompcache" ]; then
    rm -rf "$zsh_config_dir/.zcompcache"
    echo "Removed old repo-local zsh completion cache"
  fi

  unfold_config_dir "$HOME/.config/zsh" "$zsh_config_dir" local.zsh secrets.zsh
  unfold_config_dir "$HOME/.config/fish" "$fish_config_dir" local.fish secrets.fish fish_variables
  mkdir -p "$HOME/.config/fish"
  migrate_local_file "$zsh_config_dir/local.zsh" "$HOME/.config/zsh/local.zsh"
  migrate_local_file "$zsh_config_dir/secrets.zsh" "$HOME/.config/zsh/secrets.zsh"
  migrate_local_file "$fish_config_dir/fish_variables" "$HOME/.config/fish/fish_variables"
  migrate_local_file "$fish_config_dir/local.fish" "$HOME/.config/fish/local.fish"
  migrate_local_file "$fish_config_dir/secrets.fish" "$HOME/.config/fish/secrets.fish"

  src_link="$HOME/.config/src"
  starship_src="$DOTFILES_DIR/starship/.config/src"
  if [ -L "$src_link" ] && [ -d "$starship_src" ]; then
    link_target=$(
      unset CDPATH
      cd "$src_link" 2>/dev/null && pwd -P
    ) || link_target=
    expected_target=$(
      unset CDPATH
      cd "$starship_src" 2>/dev/null && pwd -P
    ) || expected_target=
    if [ -n "$link_target" ] && [ "$link_target" = "$expected_target" ]; then
      rm -f "$src_link"
      echo "Removed stale Starship source symlink at $src_link"
    fi
  fi
}

# Generate starship configs from source files
sh starship/.config/src/generate.sh

packages="
bat
fish
fzf
ghostty
git
lazygit
ripgrep
starship
tmux
zsh
"

is_group_or_world_writable() {
  [ -d "$1" ] || return 1

  mode=$(stat -f %Lp "$1" 2>/dev/null || stat -c %a "$1" 2>/dev/null) || return 1
  other=${mode#"${mode%?}"}
  mode_without_other=${mode%?}
  group=${mode_without_other#"${mode_without_other%?}"}

  case "$group$other" in
  *[2367]*) return 0 ;;
  *) return 1 ;;
  esac
}

migrate_runtime_state

for package in $packages; do
  case "$package" in
  fish | zsh)
    stow --target "$HOME" --restow --no-folding -v "$package"
    ;;
  *)
    stow --target "$HOME" --restow -v "$package"
    ;;
  esac
done

# Warn if Homebrew completion directories may trigger zsh compinit warnings.
if is_group_or_world_writable /opt/homebrew/share || is_group_or_world_writable /opt/homebrew/share/zsh; then
  echo "Warning: Homebrew share directories are group/world-writable; zsh compinit may complain."
  echo "         Review permissions manually instead of changing them recursively here."
fi

# Rebuild bat cache so custom themes are available
if command -v bat >/dev/null; then
  bat cache --clear
  bat cache --build
else
  echo "Warning: bat not found, skipping cache rebuild"
fi
