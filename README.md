# Dotfiles

Personal dotfiles, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

Durable architecture and decision records are indexed in
[`docs/index.md`](docs/index.md). Agent and maintainer guidance lives in
[`AGENTS.md`](AGENTS.md).

## Install

Install the declared tools, then deploy every package:

```sh
brew bundle
./stow_all.sh
```

The same steps work on WSL2 Ubuntu with
[Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux) installed under
`/home/linuxbrew/.linuxbrew`. Clone the repository into the Linux file system,
such as `~/github/dotfiles`, not under `/mnt/c`. `brew bundle` skips the
macOS-only entries, so install the fonts in Windows and set them in Windows
Terminal.

Git commits are unsigned until the machine opts in to a signing profile in an
untracked `~/.gitconfig`. With 1Password installed:

```ini
[include]
  path = ~/.config/git/1password.inc
```

On a host with its own key in `~/.ssh/id_ed25519`, include
`~/.config/git/ssh-key.inc` instead and set that host's `user.name` and
`user.email` in the same file. The key and email must belong to the same
GitHub account, and the key must be added to the tracked `allowed_signers`.
