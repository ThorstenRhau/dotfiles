# ADR-0003: Generate Starship from tracked sources

Status: accepted
Recorded: 2026-09-01
Supersedes: none
Related: `starship/.config/src/`, `.gitignore`

This record is retrospective. It documents the boundary implemented by the
current repository and its retained history.

## Context

Starship needs a common prompt definition plus one palette for every supported
Token family and light or dark mode. Tracking complete copies would duplicate
the prompt and invite drift. Enabling Starship's catch-all module layout also
made prompt contents and subprocess costs change when modules were added or
detected.

## Decision

Track one prompt definition in `starship/.config/src/base.toml` and the Token
palettes in `starship/.config/src/palettes/`. Generate the unthemed fallback
and all family/mode deployable configurations with
`starship/.config/src/generate.sh`; keep those outputs ignored.

Define the prompt with an explicit `format` allowlist. Add modules deliberately
instead of inheriting every Starship module through `$all`, and omit expensive
lookups when their information does not justify their prompt cost.

## Consequences

Prompt structure has one tracked source while every supported appearance gets
a deterministic deployable config. A fresh checkout must run the generator
before deploying Starship. New palettes must satisfy the generator's naming
checks, and new prompt modules require an intentional source change.

The explicit module list makes prompt behavior and performance more stable,
at the cost of not automatically displaying newly available Starship modules.

## Alternatives considered

Repository history documents the previous tracked-copy model and the `$all`
layout. No other alternatives are documented.

## Verification anchors

- `starship/.config/src/base.toml`: shared prompt and explicit `format`
- `starship/.config/src/palettes/`: tracked family/mode palettes
- `starship/.config/src/generate.sh`: input checks and deterministic outputs
- `.gitignore`: ignored deployable Starship configurations
- `stow_all.sh` and `sync_token_themes.sh`: generation entry points
- Git commits `9315904` and `c3d1f43`
