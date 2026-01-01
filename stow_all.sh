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
claude
fish
fzf
ghostty
git
lazygit
starship
tmux
"

for package in $packages; do
    stow --target "$HOME" --restow -v "$package"
done
