# My personal dot files

This repository contains my consolidated personal dot files.

The dot files are managed with [GNU stow](https://www.gnu.org/software/stow/) in
macOS and FreeBSD.

To link individual packages with stow use the following syntax

```sh
stow --target ~ --stow -v <directory>
```

To link everything run the _stow_all.sh_ script that is located in the root of
this repository.
