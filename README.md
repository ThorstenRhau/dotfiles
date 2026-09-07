# Dotfiles

Personal macOS dotfiles for an Apple Silicon machine, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

Durable architecture and decision records are indexed in
[`docs/index.md`](docs/index.md).

## Install

Install the declared tools, then deploy every package:

```sh
brew bundle
./stow_all.sh
```

The managed packages are `bat`, `fzf`, `ghostty`, `git`, `lazygit`, `ripgrep`,
`starship`, `tmux`, and `zsh`.

## Typography

Ghostty uses the licensed `MonoLisaCode` family for terminal cells and
`MonoLisaText` for window and tab titles. `Symbols Nerd Font Mono`, installed
through the declared Homebrew cask, is the fallback for semantic prompt and UI
icons that MonoLisa does not provide. After a macOS light/dark appearance
change, Zsh automatically reloads Ghostty at its every-third-prompt appearance
check. Idle terminals and active editors wait for that check. If CoreText does
not refresh the grade in an existing surface, open a new surface or restart
Ghostty. Font files are installed locally and are not part of this repository.

To deploy an individual package other than `zsh`, run:

```sh
stow --target "$HOME" --restow <package>
```

For Zsh, keep local files outside the repository by disabling directory folding:

```sh
stow --target "$HOME" --restow --no-folding zsh
```

Use `./stow_all.sh` when migrating an older folded Zsh deployment; it preserves
and moves existing local state before restowing.

Generate Starship configurations first when deploying `starship` alone:

```sh
sh starship/.config/src/generate.sh
```

## Colors

[Token](https://github.com/ThorstenRhau/token) is the color source of truth.
Classic Token, Token Flint, Token Temper, Token Ultra, and Token Meridian are
all available. Shell tools and Ghostty follow the macOS light or dark mode.
Tmux defaults to dark; use its prefix followed by `T` to toggle light/dark mode.
Classic Token is used until another appearance is selected:

```sh
token-theme token
token-theme token-flint
token-theme token-temper
token-theme token-ultra
token-theme token-meridian
```

Run `token-theme` without an argument to print the current appearance, or use
`token-theme next` to cycle through all five. The selection is stored under
`${XDG_STATE_HOME:-$HOME/.local/state}` rather than in Git. Existing shells
update at their next appearance check, tmux reloads the selected family while
retaining its light/dark mode, and Ghostty automatically reloads when its adapter
changes, including immediately after a `token-theme` family change.

After Token contrib files are regenerated, sync all five appearances into
this repository without modifying Token:

```sh
./sync_token_themes.sh /Users/thorre/github/token
```

The sync script also regenerates the ten ignored family/mode Starship configs
and the ignored unthemed fallback from tracked source files.
