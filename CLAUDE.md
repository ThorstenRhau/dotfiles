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

Configuration is in `fish/.config/fish/config.fish` with organized sections:

- Environment Variables - Global environment settings, editor config
- PATH - PATH management
- Homebrew - Homebrew integration (macOS ARM)
- Abbreviations - Shell abbreviations/aliases
- Appearance & Theming - Catppuccin theme system (auto-switching dark/light)
- Tool Integrations - zoxide, fzf, starship, ghostty
- Local Configuration - Sources git-ignored `secrets.fish` and `local.fish`

Additional functions live in `functions/` directory (autoloaded by Fish).

## Notes

- macOS-focused with Linux fallbacks in appearance system
- Catppuccin themes throughout (Mocha dark, Latte light)
