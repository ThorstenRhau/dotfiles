# AGENTS.md - dotfiles

Personal macOS configuration managed with GNU Stow. Each top-level package
mirrors its target path under `$HOME`; keep changes within the package that
owns the deployed file.

## Sources and generated files

- `README.md` owns installation guidance only. `Brewfile` owns Homebrew
  declarations. Typography, deployment, Git, Herdr, and Token guidance is
  below.
- `stow_all.sh` is the live full-deployment entry point. It also rebuilds
  the Bat cache. Do not run it solely for validation.
- The sibling Token repository is the color source of truth.
  `sync_token_themes.sh` imports its generated contrib files and must not
  modify that checkout. Do not hand-edit imported theme exports.
- Edit Starship's tracked sources under `starship/.config/src/`;
  `generate.sh` creates the ignored deployable configs. Do not hand-edit
  those outputs.
- Herdr's tracked non-theme preferences live in
  `herdr/.config/herdr/config.base.toml`; synchronized Token fragments live
  under `themes/`. Zsh composes the ignored `config.toml`. Do not track Herdr
  logs, sockets, sessions, pane history, or other runtime state. Tombi linting
  applies to the imported fragments, but formatting is disabled so they remain
  byte-identical to Token. Herdr does not support configuration includes, which
  is why Zsh composes the file. Zsh only replaces files carrying its generated
  header, writes the result privately, and reloads a running default Herdr
  server after the content changes.
- The Git difftastic commands come from an optional include that Zsh enables
  only when `difft` is on `PATH` at startup. Child processes inherit it; a
  nested Zsh removes it if `difft` is absent.
- The Git merge driver uses Mergiraf when available. Its conflicts and errors
  are returned directly. Without Mergiraf it falls back to `git merge-file`
  with the configured conflict style, labels, and marker size; binary
  conflicts then keep the current branch's version and stay unresolved for
  manual resolution, while other merge errors still fail.
- `token` in a generated theme filename names the theme, not a credential.
  Retain normal content and scope checks.
- In `ghostty/.config/ghostty/config.ghostty`, validate terminal and prompt
  glyphs with `MonoLisaCode`, titles with `MonoLisaText`, and fallback icons
  with `Symbols Nerd Font Mono`.
- Preserve ignored local configuration, secrets, history, caches, appearance
  adapters, and other runtime state.

Do not run deployment, synchronization, or cleanup actions solely for
validation.

## Deployment

The managed packages are `bat`, `fzf`, `ghostty`, `git`, `herdr`, `lazygit`,
`ripgrep`, `starship`, `tmux`, `yamllint`, and `zsh`. Herdr is the primary
persistent terminal workspace manager. The tmux package remains as a fallback,
but tmux itself is not declared in the `Brewfile`.

To deploy an individual package other than `herdr` or `zsh`:

```sh
stow --target "$HOME" --restow <package>
```

Herdr and Zsh keep runtime and local files outside the repository by disabling
directory folding:

```sh
stow --target "$HOME" --restow --no-folding herdr
stow --target "$HOME" --restow --no-folding zsh
```

After deploying Herdr, open a new interactive Zsh shell to generate its active
configuration. When deploying `starship` alone, generate its configurations
first with `sh starship/.config/src/generate.sh`.

## Typography

Ghostty uses the licensed `MonoLisaCode` family for terminal cells and
`MonoLisaText` for window and tab titles. `Symbols Nerd Font Mono`, installed
through the declared Homebrew cask, is the fallback for semantic prompt and UI
icons that MonoLisa does not provide. After a macOS light/dark appearance
change, Zsh automatically reloads Ghostty at its every-third-prompt appearance
check. Idle terminals and active editors wait for that check. If CoreText does
not refresh the grade in an existing surface, open a new surface or restart
Ghostty. Font files are installed locally and are not part of this repository.

## Git structural diffs

Delta remains the normal Git pager and interactive staging filter. Interactive
Zsh enables these optional commands when `difft` is on `PATH` at startup:

```sh
git difft                         # Working tree diff
git dshow HEAD                    # Commit with structural diff
git dlog -5                       # History with structural patches
git difftool -t difftastic        # Explicit difftool selection
```

Open a new shell after installing or removing difftastic. Difftastic uses its
native adaptive side-by-side layout, syntax highlighting, three context lines,
and automatic terminal width. The commands use `less -FRX` to preserve colors,
exit for short output, and leave the result visible. Automatic color detection
keeps redirected output plain. Ghostty's existing Token ANSI palette supplies
terminal colors; no extra theme export is needed.

On macOS, Zsh sets `DFT_BACKGROUND` at startup and updates it at the next
scheduled appearance check, every third prompt. Changes affect subsequent
difftastic invocations; idle shells wait until another prompt. Override display
options for individual commands as needed:

```sh
DFT_DISPLAY=inline git difft
DFT_DISPLAY=side-by-side-show-both DFT_CONTEXT=5 git dshow HEAD
DFT_WIDTH=120 DFT_BACKGROUND=light git difft
```

## Git merges

Mergiraf handles Git merges for all files and detects supported languages
automatically. Other text files use ordinary text merging, and so does every
file when `mergiraf` is missing from `PATH`.

## Herdr

Herdr starts with its sidebar hidden; `Ctrl-B`, then `B` toggles it. The sidebar
uses attention-priority agent ordering and status symbols. Panes have outer
frames with agent labels and Herdr's built-in gaps between them. A single pane
is also framed. The bottom tab bar is hidden for a single tab. Expanded sidebar
rows use bold workspace names and dim secondary details. `Ctrl-B` retains the
standard prefix actions, while `Alt` plus an arrow focuses an adjacent pane
directly. New tabs and workspaces prompt for names. Herdr's worktree creation
binding is disabled.

Background-agent notifications use Ghostty's terminal notification support
after a one-second delay, without sounds. Experimental pane-history persistence
is explicitly disabled because saved terminal output may contain sensitive
data. The Codex integration is not installed, so Codex panes do not natively
resume their conversations after a full Herdr restart.

`~/.config/herdr/config.toml` is generated from the tracked `config.base.toml`
and the selected Token fragment. Settings UI edits to it are temporary; durable
preferences belong in the tracked base and durable colors belong in Token. After
editing `config.base.toml` or synchronizing themes, open a new interactive Zsh
shell to regenerate the active configuration.

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
update at their next appearance check, Herdr replaces its active family
fragment, tmux reloads the selected family while retaining its light/dark mode,
and Ghostty automatically reloads when its adapter changes, including
immediately after a `token-theme` family change.

After Token contrib files are regenerated, sync all five appearances into this
repository without modifying Token:

```sh
./sync_token_themes.sh ~/github/token
```

The sync script also regenerates the ten ignored family/mode Starship configs
and the ignored unthemed fallback from tracked source files.

## Conventions

- Keep existing repository automation POSIX `sh`; keep Zsh-specific behavior
  under `zsh/`.

## Validation

Run only checks relevant to the changed package.

- POSIX shell: `sh -n <files>`, `shellcheck <files>`, and
  `shfmt -d -ci -i 2 <files>`.
- Zsh: `zsh -n <files>`.
- Zsh regression tests:
  `uv run --no-project --offline python -m unittest discover -s tests -v`.
- TOML: `tombi lint --offline --error-on-warnings .` and
  `tombi format --check --offline .`.
- Ghostty:
  `ghostty +validate-config --config-file=ghostty/.config/ghostty/config.ghostty`.
- Herdr: compose `config.base.toml` with each theme fragment and run
  `HERDR_CONFIG_PATH=<composed-file> herdr config check`.
- Markdown: `rumdl check <files>`.
- Stow layout:
  `stow --simulate --restow --target <temporary-home> <package>`; add
  `--no-folding` for `herdr` and `zsh`. Never point validation at the live home
  directory.
