# AI Assistant Instructions

Personal dotfiles for macOS Tahoe 26.2, managed with GNU Stow.

## Repository Structure

Packages: `bat`, `claude`, `fish`, `fzf`, `gemini`, `ghostty`, `git`, `lazygit`,
`ripgrep`, `starship`, `tasks`, `tmux`

Each package mirrors `$HOME/.config/` structure:

```
fish/.config/fish/config.fish → ~/.config/fish/config.fish
```

Symlink with `stow <package>` or `./stow_all.sh`.

## Key Files

- `fish/.config/fish/config.fish` - Main shell configuration
- `ghostty/.config/ghostty/config` - Terminal emulator configuration
- `starship/.config/src/` - Starship theme source files
- `Brewfile` - Homebrew package dependencies

## Starship Theme Generation

Theme configs are generated from source files in `starship/.config/src/`:

```
base.toml         # Shared config (symbols, settings)
palette_dark.toml # Dark theme palette (defines palette name + colors)
palette_light.toml# Light theme palette (defines palette name + colors)
generate.fish     # Combines base + palette into final configs
```

**To change color themes:**

1. Update `palette_dark.toml` and/or `palette_light.toml` with new palette name
   and colors (the `palette = "name"` line is extracted automatically)
2. Run `fish starship/.config/src/generate.fish`
3. Regenerated files appear in `starship/.config/`

The generator extracts the palette name from each palette file, so only the
palette files need updating when switching themes.

## Development Guidelines

### Fish Shell

- Use event-driven patterns (see `fish_prompt.fish`, `on_variable_PWD.fish`)
- Keep functions focused and single-purpose in separate files
- Prefer `command -v` over `which` for command existence checks
- Use proper error handling for external commands
- Test shell changes with `fish -c "source ~/.config/fish/config.fish"`

### File Modifications

- Preserve stow-compatible directory structure
- Maintain existing color scheme logic (Modus Vivendi/Operandi auto-switching)
- Keep function files in `fish/.config/fish/functions/` with `.fish` extension
- Use descriptive function names matching filename (e.g., `my_function.fish`
  contains `function my_function`)

### Security

- NEVER commit secrets - use git-ignored `secrets.fish` or `local.fish`
- Check for hard coded credentials before any git operations
- Use environment variables for sensitive configuration

### Dependencies

- Only add to `Brewfile` if truly necessary
- Verify package availability via Homebrew before adding
- Document any non-obvious package purposes

### Testing

- Validate fish syntax: `fish -n <file>`
- Test functions in isolated shell before committing
- Verify stow symlinks don't conflict: `stow -n <package>`
