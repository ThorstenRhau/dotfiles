# ADR-0004: Retire legacy state migrations from deployment

Status: accepted
Recorded: 2026-10-12
Supersedes: none
Superseded by: none
Related: `stow_all.sh`, ADR-0001

This record amends the deployment description in ADR-0001. The package
layout and the external runtime state boundary from that record are
unchanged.

## Context

`stow_all.sh` carried one-time migrations added between 2026-04 and
2026-09: moving repo-local Zsh history, compdump, and completion cache to
XDG paths, unfolding a symlinked `~/.config/zsh`, moving `local.zsh` and
`secrets.zsh` out of the package, and removing a stale `~/.config/src`
Starship symlink. Those migrations made up about half of the script, could
only be exercised on a machine that still had the legacy layout, and a fresh
clone never has that layout.

## Decision

Remove the migrations from `stow_all.sh`. The script is now a plain
deployment step: generate Starship configurations, restow every package
(with `--no-folding` for `herdr` and `zsh`), warn about group- or
world-writable Homebrew share directories, and rebuild the Bat cache.

The runtime state boundary is enforced by `.gitignore`, the package-local
`.stow-local-ignore` files, and the Zsh startup files, which create the XDG
state and cache directories themselves.

## Consequences

The deployment script is no longer stateful and needs no migration tests. A
machine that still has the legacy layout when it next pulls this repository
can run the previous script once from history (commit `0446115` is the last
one that contains it) before deploying normally.

## Alternatives considered

Keeping the migrations indefinitely was the status quo; no other
alternatives are documented.

## Verification anchors

- `stow_all.sh`: deployment steps after this change
- `zsh/.config/zsh/.zshrc`: creates the XDG state and cache directories
- `.gitignore` and `*/.stow-local-ignore`: runtime state boundary
- Commit `0446115`: last revision of `stow_all.sh` with the migrations
- ADR-0001: original description of the stateful script
