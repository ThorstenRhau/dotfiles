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
