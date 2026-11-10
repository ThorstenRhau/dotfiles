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
