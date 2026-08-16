# AGENTS.md - dotfiles

Personal macOS configuration managed with GNU Stow. Keep changes within the
top-level package that owns the target configuration.

## Project sources

- `README.md` owns the installation overview, managed-package list, and Token
  theme synchronization entry point.
- `Brewfile` owns the declared Homebrew package set.
- Each top-level package directory owns the files deployed to the matching paths
  under the user's home directory.
- `stow_all.sh` owns full deployment and runtime-state migration.
  `sync_token_themes.sh` owns the import of generated themes from the sibling
  Token repository.

Do not run deployment, update, sync, or cleanup behavior solely as validation.
Preserve ignored local configuration, secrets, history, caches, and other
runtime state.

## Durable project knowledge

- Use the global `$project-knowledge` workflow when explicitly asked to capture,
  audit, or promote durable knowledge for this repository.
- Keep always-applicable operating rules and the source map in `AGENTS.md`. Keep
  user-facing installation and synchronization guidance in `README.md`.
- Record accepted, non-obvious rationale under `docs/decisions/` only when it
  meets the workflow's capture threshold. Add `docs/index.md` only when the
  repository has multiple durable knowledge sources that need routing.
- Update the owning current-state document in the same scoped change that
  invalidates it. Keep session summaries, branch state, speculative notes, and
  active work out of durable project documentation.
