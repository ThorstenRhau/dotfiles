# AGENTS.md - dotfiles

Personal macOS configuration managed with GNU Stow. Each top-level package
mirrors its target path under `$HOME`; keep changes within the package that
owns the deployed file.

## Sources and generated files

- `README.md` owns installation, managed-package, typography, and Token
  synchronization guidance. `Brewfile` owns Homebrew declarations.
- `stow_all.sh` is the live full-deployment entry point. It also migrates
  private and runtime state and rebuilds the Bat cache. Do not run it solely
  for validation.
- The sibling Token repository is the color source of truth.
  `sync_token_themes.sh` imports its generated contrib files and must not
  modify that checkout. Do not hand-edit imported theme exports.
- Edit Starship's tracked sources under `starship/.config/src/`;
  `generate.sh` creates the ignored deployable configs. Do not hand-edit
  those outputs.
- `token` in a generated theme filename names the theme, not a credential.
  Retain normal content and scope checks.
- In `ghostty/.config/ghostty/config.ghostty`, validate terminal and prompt
  glyphs with `MonoLisaCode`, titles with `MonoLisaText`, and fallback icons
  with `Symbols Nerd Font Mono`.
- Preserve ignored local configuration, secrets, history, caches, appearance
  adapters, and other runtime state.

Do not run deployment, synchronization, or cleanup actions solely for
validation.

## Conventions

- Keep existing repository automation POSIX `sh`; keep Zsh-specific behavior
  under `zsh/`.

## Validation

Run only checks relevant to the changed package.

- POSIX shell: `sh -n <files>`, `shellcheck <files>`, and
  `shfmt -d -ci -i 2 <files>`.
- Zsh: `zsh -n <files>`.
- TOML: `tombi lint --offline --error-on-warnings .` and
  `tombi format --check --offline .`.
- Ghostty:
  `ghostty +validate-config --config-file=ghostty/.config/ghostty/config.ghostty`.
- Markdown: `markdownlint <files>`.
- Stow layout:
  `stow --simulate --restow --target <temporary-home> <package>`; add
  `--no-folding` for `zsh`. Never point validation at the live home
  directory.
