# AGENTS.md - dotfiles

Personal macOS configuration managed with GNU Stow, also used on WSL2 Ubuntu
with Homebrew on Linux. Each top-level package mirrors its target path under
`$HOME`; keep changes within the package that owns the deployed file.

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
- Keep Zsh working on both macOS and WSL2 Ubuntu. Take Homebrew paths from
  `HOMEBREW_PREFIX`, guard macOS-only commands with `_OS_TYPE`, and on WSL2
  use only commands that ship with Windows or the Ubuntu base system.

## Architecture

[docs/configuration-architecture.md](docs/configuration-architecture.md)
describes how the configuration works: package ownership, the Token sync and
Starship generation, runtime appearance, Git signing and diffs, Herdr
composition, and typography. Read the relevant section before changing those
areas, and update it in the same change.

## Deployment

`stow_all.sh` is the live full-deployment entry point.

To deploy an individual package other than `herdr`, `tuicr`, or `zsh`:

```sh
stow --target "$HOME" --restow <package>
```

Herdr, tuicr, and Zsh keep runtime and local files outside the repository by
disabling directory folding:

```sh
stow --target "$HOME" --restow --no-folding herdr
stow --target "$HOME" --restow --no-folding tuicr
stow --target "$HOME" --restow --no-folding zsh
```

After deploying Herdr, open a new interactive Zsh shell to generate its active
configuration. When deploying `starship` alone, generate its configurations
first with `sh starship/.config/src/generate.sh`.

## Colors

[Token](https://github.com/ThorstenRhau/token) is the color source of truth.
Select one of its six appearances with `token-theme` and one of `token`,
`token-flint`, `token-temper`, `token-ultra`, `token-meridian`, or
`token-melange`; `token-theme next` cycles and no argument prints the current
one. Do not store the selection in Git.

After Token contrib files are regenerated, sync all six appearances into this
repository:

```sh
./sync_token_themes.sh ~/github/token
```

The script must not modify the Token checkout. Edit Starship's tracked sources
under `starship/.config/src/`, never the generated configs.

## Git

- Signing is machine-local (ADR-0005). Never enable signing or require a key
  in the tracked Git configuration; machines opt in from their untracked
  `~/.gitconfig`.
- Do not set `pager.difftool`: it applies to every difftool and takes the
  terminal away from Neovim.

## Herdr

- Change preferences in `herdr/.config/herdr/config.base.toml` and colors in
  Token, never in the composed `config.toml`.
- Keep Tombi formatting disabled for the imported fragments so they stay
  byte-identical to Token.
- Do not track Herdr logs, sockets, sessions, pane history, or other runtime
  state.

## Typography

In `ghostty/.config/ghostty/config.ghostty`, validate terminal and prompt
glyphs, titles, and fallback icons against `MonoLisaCode`, `MonoLisaText`, and
`Symbols Nerd Font Mono`.

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
  `--no-folding` for `herdr`, `tuicr`, and `zsh`. Never point validation at
  the live home directory.
