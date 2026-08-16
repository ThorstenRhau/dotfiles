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
Classic Token, Token Flint, and Token Temper are all available, with macOS
continuing to select the matching light or dark mode automatically. Classic
Token is used until another appearance is selected:

```sh
token-theme token
token-theme token-flint
token-theme token-temper
```

Run `token-theme` without an argument to print the current appearance, or use
`token-theme next` to cycle through all three. The selection is stored under
`${XDG_STATE_HOME:-$HOME/.local/state}` rather than in Git. Existing shells
update at their next appearance check, tmux reloads when running, and Ghostty
windows can be updated with `Cmd+Shift+,`.

After Token contrib files are regenerated, sync all three appearances into
this repository without modifying Token:

```sh
./sync_token_themes.sh /Users/thorre/github/token
```

The sync script also regenerates the six ignored family/mode Starship configs
and the unthemed fallback from tracked source files.
