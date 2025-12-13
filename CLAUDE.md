# CLAUDE.md

Personal dotfiles repository managed with GNU Stow.

## Structure

Each top-level directory (bat, fish, fzf, ghostty, git, lazygit, starship, tmux)
is a "package" that mirrors `$HOME/.config/`:

```
dotfiles/fish/.config/fish/config.fish  →  ~/.config/fish/config.fish
```

Run `stow <package>` or `./stow_all.sh` to create symlinks.

## Fish Shell

Config lives in modular files under `conf.d/` (sourced alphabetically):

- `00-env.fish` - Environment variables
- `01-path.fish` - PATH management
- `02-brew.fish` - Homebrew integration
- `10-abbreviations.fish` - Aliases
- `15-appearance.fish` - Theme system
- `20-tools.fish` - Tool integrations (zoxide, fzf, starship)
- `99-locals.fish` - Sources git-ignored `secrets.fish` and `local.fish`

Edit `conf.d/*.fish` files, not `config.fish`.

## Notes

- macOS-focused with Linux fallbacks in appearance system
- Catppuccin themes throughout (Mocha dark, Latte light)
