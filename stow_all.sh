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
kitty
lazygit
ripgrep
starship
tmux
tuicr
yamllint
zsh
"

for package in $packages; do
  case "$package" in
    herdr | tuicr | zsh)
      stow --target "$HOME" --restow --no-folding -v "$package"
      ;;
    *)
      stow --target "$HOME" --restow -v "$package"
      ;;
  esac
done

# Rebuild bat cache so custom themes are available
if command -v bat >/dev/null; then
  bat cache --clear
  bat cache --build
else
  echo "Warning: bat not found, skipping cache rebuild"
fi
