#!/bin/sh

# This script links all dot files with the GNU stow command

if ! command -v stow >/dev/null; then
  echo "Error: 'stow' command not found. Please install it to continue."
  exit 1
fi

# Generate starship configs from source files
if command -v fish >/dev/null; then
  fish starship/.config/src/generate.fish
else
  echo "Warning: fish not found, skipping starship config generation"
fi

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

for package in $packages; do
  stow --target "$HOME" --restow -v "$package"
done

# Fix Homebrew share dir permissions so zsh compinit doesn't complain
if [ -d /opt/homebrew/share ]; then
  chmod go-w /opt/homebrew/share
  chmod -R go-w /opt/homebrew/share/zsh
fi

# Rebuild bat cache so custom themes are available
if command -v bat >/dev/null; then
  bat cache --clear && bat cache --build
else
  echo "Warning: bat not found, skipping cache rebuild"
fi
