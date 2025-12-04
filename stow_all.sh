#!/bin/sh

# This script links all dot files with the GNU stow command

if ! command -v stow >/dev/null; then
    echo "Error: 'stow' command not found. Please install it to continue."
    exit 1
fi

packages="
bat
fish
fzf
ghostty
git
lazygit
starship
"

for package in $packages; do
    stow --target "$HOME" --restow -v "$package"
done
