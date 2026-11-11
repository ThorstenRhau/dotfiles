# AGENTS.md - dotfiles

Personal macOS configuration managed with GNU Stow. Each top-level package
mirrors its target path under `$HOME`; keep changes within the package that
owns the deployed file.

## Rules

- `README.md` owns installation guidance only. `Brewfile` owns Homebrew
  declarations. Deployment, color, Git, Herdr, and typography guidance is
  below.
- Do not run deployment, synchronization, or cleanup actions solely for
  validation. That includes `stow_all.sh` and `sync_token_themes.sh`.
- Do not hand-edit generated or imported files: the Token theme exports, the
  generated Starship configs, and Herdr's composed `config.toml`. Change their
  sources instead; the sections below name them.
- Preserve ignored local configuration, secrets, history, caches, appearance
  adapters, and other runtime state.
- `token` in a generated theme filename names the theme, not a credential.
  Retain normal content and scope checks.
- Keep existing repository automation POSIX `sh`; keep Zsh-specific behavior
  under `zsh/`.

## Deployment

The managed packages are `bat`, `fzf`, `ghostty`, `git`, `herdr`, `kitty`,
`lazygit`, `ripgrep`, `starship`, `tmux`, `yamllint`, and `zsh`. Herdr is the primary
persistent terminal workspace manager. The tmux package remains as a fallback,
but tmux itself is not declared in the `Brewfile`.

`stow_all.sh` is the live full-deployment entry point. It also rebuilds the Bat
cache.

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

## Colors

[Token](https://github.com/ThorstenRhau/token) is the color source of truth.
Its six appearances are Classic Token, Token Flint, Token Temper, Token Ultra,
Token Meridian, and Token Melange. Shell tools and Ghostty follow the macOS
light or dark mode. Herdr follows the appearance reported by Ghostty and uses
both modes from the selected family fragment. Tmux defaults to dark; use its
prefix followed by `T` to toggle light/dark mode. Classic Token is used until
another appearance is selected:

```sh
token-theme token
token-theme token-flint
token-theme token-temper
token-theme token-ultra
token-theme token-meridian
token-theme token-melange
```

Run `token-theme` without an argument to print the current appearance, or use
`token-theme next` to cycle through all six. The selection is stored under
`${XDG_STATE_HOME:-$HOME/.local/state}` rather than in Git. Existing shells
update at their next appearance check, Herdr replaces its active family
fragment, tmux reloads the selected family while retaining its light/dark mode,
and Ghostty automatically reloads when its adapter changes, including
immediately after a `token-theme` family change.

After Token contrib files are regenerated, sync all six appearances into this
repository:

```sh
./sync_token_themes.sh ~/github/token
```

The script imports Token's generated contrib files and must not modify the
Token checkout. It also runs the Starship generator.

Starship's tracked sources live under `starship/.config/src/`. `generate.sh`
creates the ignored deployable configs from them: one per appearance and mode,
plus an unthemed fallback.

## Git

### Diffs in the terminal

Delta is the Git pager and the interactive staging filter. It shows diffs side
by side and wraps long lines in full.

Interactive Zsh adds structural diff commands through an optional Git include,
only when `difft` is on `PATH` at startup. Child processes inherit the include;
a nested Zsh removes it if `difft` is absent. Open a new shell after installing
or removing difftastic.

```sh
git difft                         # Working tree diff
git dshow HEAD                    # Commit with structural diff
git dlog -5                       # History with structural patches
git difftool -t difftastic        # Explicit difftool selection
```

Difftastic uses its native adaptive side-by-side layout, syntax highlighting,
three context lines, and automatic terminal width. The commands use `less -FRX`
to preserve colors, exit for short output, and leave the result visible.
Automatic color detection keeps redirected output plain. Ghostty's existing
Token ANSI palette supplies terminal colors; no extra theme export is needed.

The difftastic difftool pages its own output. Do not set `pager.difftool`: it
applies to every difftool and takes the terminal away from Neovim.

On macOS, Zsh sets `DFT_BACKGROUND` at startup and updates it at the next
scheduled appearance check, every third prompt. Changes affect subsequent
difftastic invocations; idle shells wait until another prompt. Override display
options for individual commands as needed:

```sh
DFT_DISPLAY=inline git difft
DFT_DISPLAY=side-by-side-show-both DFT_CONTEXT=5 git dshow HEAD
DFT_WIDTH=120 DFT_BACKGROUND=light git difft
```

### Diffs in Neovim

`git difftool` opens Neovim's built-in `nvim.difftool`, one file at a time.
`git dt [<revision>...]` is `git difftool -d`: it opens the whole changeset,
with the changed files in the quickfix list and each one as a side-by-side
diff.

### Lazygit

Lazygit renders diffs with delta, unified when the diff view is narrower than
160 columns and side by side above that. `|` cycles to difftastic.

### Merges

Mergiraf handles Git merges for all files and detects supported languages
automatically. Its conflicts and errors are returned directly. Other text files
use ordinary text merging.

When `mergiraf` is missing from `PATH`, the merge driver falls back to
`git merge-file` with the configured conflict style, labels, and marker size.
Binary conflicts then keep the current branch's version and stay unresolved for
manual resolution, while other merge errors still fail.

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

Herdr does not support configuration includes, so Zsh composes the ignored
`~/.config/herdr/config.toml` from two tracked sources: the non-theme
preferences in `herdr/.config/herdr/config.base.toml` and the selected Token
fragment under `themes/`. Zsh only replaces files carrying its generated
header, writes the result privately, and reloads a running default Herdr server
after the content changes.

Settings UI edits to `config.toml` are temporary; durable preferences belong in
the tracked base and durable colors belong in Token. After editing
`config.base.toml` or synchronizing themes, open a new interactive Zsh shell to
regenerate the active configuration.

Tombi linting applies to the imported fragments, but formatting is disabled so
they remain byte-identical to Token. Do not track Herdr logs, sockets, sessions,
pane history, or other runtime state.

## Typography

Ghostty uses the licensed `MonoLisaCode` family for terminal cells and
`MonoLisaText` for window and tab titles. `Symbols Nerd Font Mono`, installed
through the declared Homebrew cask, is the fallback for semantic prompt and UI
icons that MonoLisa does not provide. In
`ghostty/.config/ghostty/config.ghostty`, validate terminal and prompt glyphs,
titles, and fallback icons against those three fonts. Font files are installed
locally and are not part of this repository.

After a macOS light/dark appearance change, Zsh automatically reloads Ghostty
at its every-third-prompt appearance check. Idle terminals and active editors
wait for that check. If CoreText does not refresh the grade in an existing
surface, open a new surface or restart Ghostty.

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
  It does not compile `shaders/cursor-effects.glsl`. When any custom shader
  fails to load or compile, Ghostty drops all of them and reports it only in
  its log (`log show --last 5m --predicate 'process == "ghostty"'`).
- Kitty: parse the config with `kitty +runpy` and
  `kitty.config.load_config(path, accumulate_bad_lines=bad)`; `bad` must be
  empty.
- Herdr: compose `config.base.toml` with each theme fragment and run
  `HERDR_CONFIG_PATH=<composed-file> herdr config check`.
- Markdown: `rumdl check <files>`.
- Stow layout:
  `stow --simulate --restow --target <temporary-home> <package>`; add
  `--no-folding` for `herdr` and `zsh`. Never point validation at the live home
  directory.
