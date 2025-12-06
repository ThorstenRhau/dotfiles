# Project Context: Dotfiles

## Overview

This repository contains personal dotfiles for macOS (Darwin), managed using
**GNU Stow**. It centralizes configuration for shell environments, command-line
tools, and terminal emulators, allowing for easy deployment and synchronization
across machines.

## Architecture

The project follows a standard Stow directory structure where top-level folders
represent "packages" that are symlinked into the user's home directory (`~`).

- **Package Management:** [GNU Stow](https://www.gnu.org/software/stow/)
- **Dependency Management:** [Homebrew](https://brew.sh/) (`Brewfile`)
- **Target OS:** macOS (Darwin)

## Key Configurations

### Shell Environment

- **Fish:** Is the primary shell
  - Configuration: `fish/.config/fish/config.fish`
  - Features:
    - **Plugin Manager:** none
    - **Prompt:** Starship (`starship init fish`)
    - **Navigation:** Zoxide (`z`)
    - **Fuzzy Finding:** FZF integration
    - **Aliases/Abbr:** Extensive git abbreviations (`gc`, `gst`, etc.), `ls` ->
      `eza`, `cat` -> `bat`.
- **Zsh:** Alternate / fallback that is not used regularly.
  - Configuration: `zsh/.zshrc`

### Tools & Applications

- **Editor:** Neovim (`nvim`) is set as the default `EDITOR` and `VISUAL`. The
  neovim configuration resides in a different repository.
- **Terminal:** Ghostty (`ghostty/`) with theme support (Catppuccin, Tokyo
  Night, Kanagawa).
- **Git:** Configured via `git/.config/git/config` and `lazygit`.
- **Utilities:**
  - `bat`: Cat replacement with syntax highlighting.
  - `eza`: Ls replacement.
  - `fzf`: Fuzzy finder.
  - `zoxide`: Smarter `cd`.

## Installation & Usage

### 1. Install Dependencies

Dependencies are defined in the `Brewfile`.

```sh
brew bundle
```

### 2. Link Configurations

The `stow_all.sh` script automates linking all packages to `$HOME`.

```sh
./stow_all.sh
```

Alternatively, link individual packages:

```sh
stow --target ~ --restow -v <package_name>
# Example: stow --target ~ --restow -v fish
```

## Development Conventions

- **Formatting:**
  - **Lua:** Configured via `.stylua.toml` (Indent: 2 spaces, Quote:
    AutoPreferSingle).
  - **General:** `.prettierrc.toml` and `.editorconfig` enforce consistent
    coding styles.
- **Shell Scripting:**
  - Fish scripts use idiomatic `abbr` for aliases.
  - Environment variables are managed centrally in shell configs (e.g.,
    `HOMEBREW_*`, `XDG_CONFIG_HOME`).
- **Secrets:**
  - Shell configurations look for local/secret files (`secrets.fish`,
    `.zshrc_secrets`) which are git-ignored.
