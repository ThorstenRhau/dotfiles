# ADR-0005: Enable Git signing per machine

Status: accepted
Recorded: 2026-11-16
Supersedes: none
Superseded by: none
Related: `git/.config/git/`, ADR-0001

## Context

`github.inc` set the 1Password `op-ssh-sign` program and key for every GitHub
remote, and the main configuration turned on commit and tag signing for every
repository. On machines without 1Password, such as mighty.home and WSL2,
every commit or annotated tag in a GitHub repository failed, unless that
repository overrode the settings in its own `.git/config`. mighty.home has
its own signing key, `~/.ssh/id_ed25519`, for the MightyHome machine account,
and all commits made there should be signed with it.

## Decision

The tracked configuration keeps only what every machine can satisfy:
`gpg.format = ssh`, the shared `allowed_signers` file, and the personal email
for GitHub remotes. Two tracked profiles hold the signing settings:
`1password.inc` and `ssh-key.inc`. Each turns on `commit.gpgsign` and
`tag.gpgSign`. A machine opts in through an untracked `~/.gitconfig` that
includes one profile. Git reads that file after `~/.config/git/config`, so it
can also set the machine's identity. A missing `~/.gitconfig` leaves signing
off.

## Consequences

tesseract.home and mighty.home each need a hand-written `~/.gitconfig`; the
README shows both. Machines without one create unsigned commits instead of
failing. `git config --global` writes go to `~/.gitconfig` instead of the
stowed file in this checkout. Signing on mighty.home is the default, not
enforced: `--no-gpg-sign` still skips it, and only a GitHub ruleset can
require signatures.

## Alternatives considered

- Adding the 1Password include from Zsh through `_git_env_include`: Git run
  outside an interactive Zsh, such as from the Claude app, would stop signing
  on tesseract.home.
- Keeping signing required everywhere: commits on unconfigured machines
  would still fail, only with a clearer error.
- Writing `~/.gitconfig` from `stow_all.sh`: it would make deployment
  stateful again, which ADR-0004 removed.

## Verification anchors

- `git/.config/git/1password.inc` and `git/.config/git/ssh-key.inc`
- `git/.config/git/github.inc` and `git/.config/git/config`
- `git/.config/git/allowed_signers`
- `README.md`: the `~/.gitconfig` opt-in
