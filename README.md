# Dotfiles

Personal macOS dotfiles for an Apple Silicon machine, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

## Install

Install the declared tools, then deploy every package:

```sh
brew bundle
./stow_all.sh
```

The managed packages are `bat`, `fzf`, `ghostty`, `git`, `lazygit`, `ripgrep`,
`starship`, `tmux`, and `zsh`.

To deploy an individual package, run:

```sh
stow --target "$HOME" --restow <package>
```

Generate Starship configurations first when deploying `starship` alone:

```sh
sh starship/.config/src/generate.sh
```

## Colors

[Token](https://github.com/ThorstenRhau/token) is the color source of truth.
After Token contrib files are regenerated, sync the derived files into this
repository without modifying Token:

```sh
./sync_token_themes.sh /Users/thorre/github/token
```

The sync script also regenerates the ignored Starship light, dark, and fallback
configs from the tracked source files.
