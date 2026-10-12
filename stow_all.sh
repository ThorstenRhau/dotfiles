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

# Generate starship configs from source files
sh starship/.config/src/generate.sh

packages="
bat
fzf
ghostty
git
herdr
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

for package in $packages; do
  case "$package" in
    herdr | zsh)
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
