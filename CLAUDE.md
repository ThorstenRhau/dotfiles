# AI Assistant Instructions

Personal macOS dotfiles for an Apple Silicon machine, managed with GNU Stow.

## Packages and deployment

Packages are `bat`, `fzf`, `ghostty`, `git`, `lazygit`, `ripgrep`, `starship`,
`tmux`, and `zsh`. They mirror the target home directory, for example:

```text
zsh/.config/zsh/.zshrc -> ~/.config/zsh/.zshrc
```

Use `./stow_all.sh` for the supported full deployment. For an individual
package, run `stow --target "$HOME" --restow <package>`; generate Starship
configs first when deploying `starship` alone.

## Zsh

- ZDOTDIR is `~/.config/zsh`, bootstrapped by `~/.zshenv`.
- Plugins are sourced from Homebrew. Keep fast syntax highlighting as the final
  sourced plugin in `.zshrc`.
- Put autoloaded functions in `zsh/.config/zsh/functions/`.
- Keep private `local.zsh` and `secrets.zsh` outside the repository.
- Validate syntax with `zsh -n <file>` and start changed behavior in an isolated
  shell before deployment.

## Token colors

Token is the source of truth for every application color. Do not edit generated
theme files manually. The `token-theme` Zsh command selects `token`,
`token-flint`, `token-temper`, or `token-ultra`; macOS continues to select light
or dark mode.
The local selection and generated Ghostty/tmux adapters must remain untracked.
After Token contrib files change, run:

```sh
./sync_token_themes.sh /Users/thorre/github/token
```

The script updates all four tracked theme families and regenerates the eight
ignored Starship family/mode configs from `starship/.config/src/`. It must not
modify the Token checkout.

## Standalone scripts and safety

- Write utility scripts in POSIX sh or bash.
- Preserve Stow-compatible paths and local-file migration behavior.
- Never commit secrets, local state, generated Starship configs, or credentials.
- Add dependencies to `Brewfile` only when they have a documented purpose.
- Prefer validation in temporary homes and repositories. Do not run destructive
  helpers against a real checkout while testing.

## Validation

- Shell: `sh -n`, `shellcheck`, `shfmt -d`, and `zsh -n` as appropriate.
- Data: TOML, JSON, and YAML parsing with the installed tooling.
- Deployment: `stow --simulate --restow <package>` before a live restow.
- Tool configs: use the installed CLI's validation command or schema where one
  exists.
