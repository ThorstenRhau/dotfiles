# Dotfiles

Personal dotfiles managed with GNU Stow. macOS-focused, Modus themes throughout.

## Structure

Packages: `bat`, `claude`, `fish`, `fzf`, `gemini`, `ghostty`, `git`, `lazygit`, `starship`, `tasks`, `tmux`

Each mirrors `$HOME/.config/` (or `$HOME/` for dotfiles like `.gemini/`):
```
fish/.config/fish/config.fish  →  ~/.config/fish/config.fish
```

Run `stow <package>` or `./stow_all.sh` to symlink.

## Key Files

- `fish/.config/fish/config.fish` - Main shell config
- `fish/.config/fish/functions/` - Autoloaded fish functions
- `ghostty/.config/ghostty/config` - Terminal config
- `Brewfile` - Homebrew dependencies

## Notes

- Secrets in git-ignored `secrets.fish` and `local.fish`
- Appearance auto-switches between Modus Vivendi (dark) and Operandi (light)
