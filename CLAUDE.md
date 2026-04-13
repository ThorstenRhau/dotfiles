# AI Assistant Instructions

Personal dotfiles for macOS Tahoe 26.2, managed with GNU Stow.

## Repository Structure

Packages: `bat`, `claude`, `fish`, `fzf`, `gemini`, `ghostty`, `git`, `lazygit`,
`ripgrep`, `starship`, `tasks`, `tmux`, `zsh`

Each package mirrors `$HOME/.config/` structure:

```
zsh/.config/zsh/.zshrc → ~/.config/zsh/.zshrc
```

Symlink with `stow <package>` or `./stow_all.sh`.

## Key Files

- `zsh/.config/zsh/.zshrc` - Zsh shell configuration (primary shell)
- `fish/.config/fish/config.fish` - Fish shell configuration (legacy, maintained)
- `ghostty/.config/ghostty/config` - Terminal emulator configuration
- `starship/.config/src/` - Starship theme source files
- `Brewfile` - Homebrew package dependencies

## Starship Theme Generation

Theme configs are generated from source files in `starship/.config/src/`:

```
base.toml         # Shared config (symbols, settings)
palette_dark.toml # Dark theme palette (defines palette name + colors)
palette_light.toml# Light theme palette (defines palette name + colors)
generate.sh       # Combines base + palette into final configs
```

**To change color themes:**

1. Update `palette_dark.toml` and/or `palette_light.toml` with new palette name
   and colors (the `palette = "name"` line is extracted automatically)
2. Run `sh starship/.config/src/generate.sh`
3. Regenerated files appear in `starship/.config/`

The generator extracts the palette name from each palette file, so only the
palette files need updating when switching themes.

## Development Guidelines

### Zsh Shell (primary)

- ZDOTDIR is `~/.config/zsh`, bootstrapped via `~/.zshenv`
- Plugins sourced from Homebrew (`/opt/homebrew/share/` and `/opt/homebrew/opt/`)
- Autoloaded functions go in `zsh/.config/zsh/functions/`
- Fast-syntax-highlighting must be sourced last in `.zshrc`
- FZF theme files have both `.fish` and `.zsh` variants in `fzf/.config/fzf/themes/`
- Zsh syntax highlighting themes in `zsh/.config/zsh/themes/` (synced from token contrib)
- Validate syntax: `zsh -n <file>`

### Fish Shell (legacy, maintained)

- Use event-driven patterns (see `fish_prompt.fish`, `on_variable_PWD.fish`)
- Keep functions focused and single-purpose in separate files
- Prefer `command -v` over `which` for command existence checks
- Use proper error handling for external commands
- Test shell changes with `fish -c "source ~/.config/fish/config.fish"`

### Standalone Scripts

- Write in POSIX sh or bash, not fish or zsh
- Keep portable: avoid shell-specific syntax in utility scripts

### File Modifications

- Preserve stow-compatible directory structure
- Maintain existing color scheme logic (Modus Vivendi/Operandi auto-switching)
- Zsh autoloaded functions go in `zsh/.config/zsh/functions/`
- Fish function files go in `fish/.config/fish/functions/` with `.fish` extension

### Security

- NEVER commit secrets - use git-ignored `secrets.fish`/`local.fish` or `secrets.zsh`/`local.zsh`
- Check for hard coded credentials before any git operations
- Use environment variables for sensitive configuration

### Dependencies

- Only add to `Brewfile` if truly necessary
- Verify package availability via Homebrew before adding
- Document any non-obvious package purposes

### Testing

- Validate zsh syntax: `zsh -n <file>`
- Validate fish syntax: `fish -n <file>`
- Test functions in isolated shell before committing
- Verify stow symlinks don't conflict: `stow -n <package>`
