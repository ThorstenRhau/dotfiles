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
- `fish/.config/fish/functions/` - Autoloaded fish functions (event-driven)
- `ghostty/.config/ghostty/config` - Terminal emulator configuration
- `Brewfile` - Homebrew package dependencies

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
- Check for hardcoded credentials before any git operations
- Use environment variables for sensitive configuration

### Dependencies

- Only add to `Brewfile` if truly necessary
- Verify package availability via Homebrew before adding
- Document any non-obvious package purposes

### Testing

- Validate fish syntax: `fish -n <file>`
- Test functions in isolated shell before committing
- Verify stow symlinks don't conflict: `stow -n <package>`
