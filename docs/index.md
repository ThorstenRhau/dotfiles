# Project knowledge

## Purpose and authority

This index maps durable knowledge for the dotfiles repository. The current
repository is authoritative: `AGENTS.md` owns maintenance rules, `README.md`
owns installation and user-facing operations, `Brewfile` owns Homebrew
declarations, current-state documents describe implemented behavior, and
decision records preserve accepted rationale.

## Current-state documentation

- [Configuration architecture](configuration-architecture.md) describes
  package ownership, generation flows, deployment, and runtime state.

## Decision history

- [ADR-0001](decisions/0001-stow-packages-and-runtime-state.md): use Stow
  packages while keeping private and runtime state outside the repository.
- [ADR-0002](decisions/0002-token-owns-terminal-colors.md): use Token as the
  color source of truth and import its generated exports.
- [ADR-0003](decisions/0003-generate-starship-from-tracked-sources.md): build
  deployable Starship configurations from tracked sources and an explicit
  prompt layout.

All three records are accepted and retrospective. No records are currently
superseded, deprecated, or proposed.

## Active work

Active and proposed work belongs in the
[GitHub issue tracker](https://github.com/ThorstenRhau/dotfiles/issues), not in
this documentation.

## Release and operational evidence

- `README.md` documents installation, individual package deployment,
  typography, appearance selection, and Token synchronization.
- `AGENTS.md` defines source ownership and package-specific validation.
- Git history retains dated implementation evidence. It is not a substitute
  for current repository state.

## Maintenance

Update current-state documentation in the same change as the implementation.
Preserve accepted decision records; when a decision changes, add a new record
and mark the old one superseded. Do not retain active tasks, local machine
state, secrets, caches, transcripts, or facts that are obvious from one file.
