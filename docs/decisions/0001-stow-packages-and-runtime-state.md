# ADR-0001: Use Stow packages and external runtime state

Status: accepted
Recorded: 2026-09-01
Supersedes: none
Related: `stow_all.sh`, `.gitignore`, `zsh/.stow-local-ignore`

This record is retrospective. It documents the boundary implemented by the
current repository and its retained history.

## Context

The repository deploys configuration into `$HOME`, but Zsh and related tools
also create private overrides, secrets, history, caches, and generated runtime
files below the same configuration directories. Allowing Stow to own those
whole directories can place local-only state inside repository paths or make
it difficult for local files to coexist safely.

## Decision

Organize deployed configuration as GNU Stow packages whose contents mirror
their target paths below `$HOME`. Keep private and runtime state outside the
repository. Use `--no-folding` for the Zsh package and migrate legacy Zsh
state into XDG state, cache, or local target paths before deployment.

Treat `stow_all.sh` as an operational deployment boundary. Validate package
layout against a temporary target instead of restowing the live home solely
for validation.

## Consequences

Each tracked file has a clear owning package, and local state can coexist with
the deployed configuration without being committed. The deployment script is
necessarily stateful because it performs guarded migrations and rebuilds the
Bat cache. Package validation therefore needs a temporary Stow target and does
not prove live deployment behavior.

## Alternatives considered

No alternatives are documented in repository evidence.

## Verification anchors

- `stow_all.sh`: package list, state migration, Zsh `--no-folding`, and Bat
  cache rebuild
- `.gitignore`: ignored local state and generated adapters
- `zsh/.stow-local-ignore`: Zsh package exclusions
- `README.md`: supported package set and deployment commands
- Git commits `e81a0c7`, `5a9df94`, and `b02d31f`
