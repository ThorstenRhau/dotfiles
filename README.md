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

The managed packages are `bat`, `fzf`, `ghostty`, `git`, `herdr`, `lazygit`,
`ripgrep`, `starship`, `tmux`, and `zsh`.

Herdr is the primary persistent terminal workspace manager. The existing tmux
package remains available as a fallback, but tmux itself is not declared in the
`Brewfile`.

## Typography

Ghostty uses the licensed `MonoLisaCode` family for terminal cells and
`MonoLisaText` for window and tab titles. `Symbols Nerd Font Mono`, installed
through the declared Homebrew cask, is the fallback for semantic prompt and UI
icons that MonoLisa does not provide. After a macOS light/dark appearance
change, Zsh automatically reloads Ghostty at its every-third-prompt appearance
check. Idle terminals and active editors wait for that check. If CoreText does
not refresh the grade in an existing surface, open a new surface or restart
Ghostty. Font files are installed locally and are not part of this repository.

To deploy an individual package other than `herdr` or `zsh`, run:

```sh
stow --target "$HOME" --restow <package>
```

For Herdr and Zsh, keep runtime and local files outside the repository by
disabling directory folding:

```sh
stow --target "$HOME" --restow --no-folding herdr
stow --target "$HOME" --restow --no-folding zsh
```

Use `./stow_all.sh` when migrating an older folded Zsh deployment; it preserves
and moves existing local state before restowing. After deploying Herdr, Zsh
creates its active configuration at the next appearance check.

Generate Starship configurations first when deploying `starship` alone:

```sh
sh starship/.config/src/generate.sh
```

## Herdr

Herdr starts with its sidebar hidden; `Ctrl-B`, then `B` toggles it. The sidebar
uses attention-priority agent ordering and status symbols. Panes have outer frames
with agent labels and Herdr's built-in gaps between them. A single pane is also
framed. The bottom tab bar is hidden for a single tab. Expanded sidebar rows
use bold workspace names and dim secondary details.
`Ctrl-B` retains the standard prefix actions, while
`Alt` plus an arrow focuses an adjacent pane directly. New tabs and workspaces
prompt for names. Herdr's worktree creation binding is disabled.

Background-agent notifications use Ghostty's terminal notification support
after a one-second delay, without sounds. Experimental pane-history persistence
is explicitly disabled because saved terminal output may contain sensitive
data. The Codex integration is not installed, so Codex panes do not natively
resume their conversations after a full Herdr restart.

`~/.config/herdr/config.toml` is generated from the tracked
`config.base.toml` and selected Token fragment because Herdr does not support
configuration includes. Zsh only replaces files carrying its generated header,
writes the result privately, and reloads a running default Herdr server after
the content changes. Settings UI edits to this generated file are temporary;
durable preferences belong in the tracked base and durable colors belong in
Token.

## Colors

[Token](https://github.com/ThorstenRhau/token) is the color source of truth.
Classic Token, Token Flint, Token Temper, Token Ultra, and Token Meridian are
all available. Shell tools and Ghostty follow the macOS light or dark mode.
Herdr follows the appearance reported by Ghostty and uses both modes from the
selected family fragment. Tmux defaults to dark; use its prefix followed by `T`
to toggle light/dark mode. Classic Token is used until another appearance is
selected:

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
update at their next appearance check, Herdr replaces its active family fragment,
tmux reloads the selected family while retaining its light/dark mode, and Ghostty
automatically reloads when its adapter changes, including immediately after a
`token-theme` family change.

After Token contrib files are regenerated, sync all five appearances into
this repository without modifying Token:

```sh
./sync_token_themes.sh /Users/thorre/github/token
```

The sync script also regenerates the ten ignored family/mode Starship configs
and the ignored unthemed fallback from tracked source files.
