# ADR-0002: Use Token as the terminal color source

Status: accepted
Recorded: 2026-09-01
Supersedes: none
Related: `sync_token_themes.sh`, `zsh/.config/zsh/functions/token-theme`

This record is retrospective. It documents the boundary implemented by the
current repository and its retained history.

## Context

The same appearance families and light or dark modes are consumed by several
terminal tools. Hand-maintaining equivalent palettes in each package would
allow colors and supported appearances to drift. The user's selected family is
machine state and must not become a repository change.

## Decision

Use the sibling Token repository as the color source of truth. Import its
generated contrib exports through `sync_token_themes.sh`; keep those imported
exports tracked here, but do not edit them individually or modify the Token
checkout during synchronization.

Persist the selected appearance family in XDG state. Let Zsh combine that
family with the current macOS light or dark mode, export tool-specific selectors,
and create ignored adapters for long-running Ghostty and tmux processes.

## Consequences

A palette update has one upstream source and one synchronization path across
the supported tools. This repository still tracks imported artifacts so a
checkout contains the themes it deploys. Appearance selection and generated
adapters remain local, so changing themes does not dirty the worktree.

Synchronization is an explicit mutation, not a validation command, and must
be followed by review of all imported changes.

## Alternatives considered

Repository history records that hand-maintained per-tool themes were replaced,
but it does not document other alternatives as having been evaluated.

## Verification anchors

- `sync_token_themes.sh`: preflight, supported appearances, imports, and
  Starship regeneration
- `zsh/.config/zsh/functions/token-theme`: validated persistent family choice
- `zsh/.config/zsh/functions/_apply_appearance`: per-tool selection and local
  adapter generation
- `.gitignore`: ignored Ghostty and tmux adapters
- Git commits `52d1661` and `bc7b503`
