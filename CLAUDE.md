# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Rules for Claude

1. First think through the problem, read the codebase for relevant files, and
   write a plan to tasks/todo.md.
2. The plan should have a list of todo items that you can check off as you
   complete them
3. Before you begin working, check in with me and I will verify the plan.
4. Then, begin working on the todo items, marking them as complete as you go.
5. Please every step of the way just give me a high level explanation of what
   changes you made
6. Make every task and code change you do as simple as possible. We want to
   avoid making any massive or complex changes. Every change should impact as
   little code as possible. Everything is about simplicity.
7. Finally, add a review section to the todo.md file with a summary of the
   changes you made and any other relevant information.
8. Never add Claude attribution to commit messages (e.g., "Generated with Claude
   Code", "Co-Authored-By: Claude", or similar phrases)
9. DO NOT BE LAZY. NEVER BE LAZY. IF THERE IS A BUG FIND THE ROOT CAUSE AND FIX
   IT. NO TEMPORARY FIXES. YOU ARE A SENIOR DEVELOPER. NEVER BE LAZY
10. MAKE ALL FIXES AND CODE CHANGES AS SIMPLE AS HUMANLY POSSIBLE. THEY SHOULD
    ONLY IMPACT NECESSARY CODE RELEVANT TO THE TASK AND NOTHING ELSE. IT SHOULD
    IMPACT AS LITTLE CODE AS POSSIBLE. YOUR GOAL IS TO NOT INTRODUCE ANY BUGS.
    IT'S ALL ABOUT SIMPLICITY

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow. Each top-level
directory (bat, fish, fzf, ghostty, git, lazygit, starship) represents a
"package" that mirrors the `$HOME` directory structure. Running `stow` creates
symlinks from this repo into the home directory.

## Common Commands

### Installation and Linking

```bash
# Install all Homebrew dependencies
brew bundle

# Link all dotfiles to $HOME
./stow_all.sh

# Link a single package manually
stow --target ~ --stow -v <package_name>

# Unlink a package
stow --target ~ --delete -v <package_name>

# Re-link a package (useful after updates)
stow --target ~ --restow -v <package_name>
```

### Linting and Formatting

```bash
# Lua files
stylua --check .
luacheck .

# TOML files
taplo format --check

# General editor config
# Uses .editorconfig (2-space indent, UTF-8, 80-char lines)
```

## Architecture and Key Concepts

### GNU Stow Pattern

Each package directory contains a `.config/` subdirectory that mirrors `$HOME`:

```
dotfiles/fish/.config/fish/config.fish
          ↓ (stow creates symlink)
~/.config/fish/config.fish
```

This allows version-controlled configs to be symlinked into place without
copying files.

### Fish Shell Modular Configuration

The Fish shell config at `/fish/.config/fish/config.fish` is intentionally
minimal. All actual configuration lives in modular files under `conf.d/`, which
Fish sources automatically in alphabetical order:

- **00-env.fish** - Global environment variables (locale, editor, XDG paths)
- **01-path.fish** - PATH management (local bins, Docker, LM Studio)
- **02-brew.fish** - Homebrew integration with intelligent caching via
  `_config_cache()`
- **10-abbreviations.fish** - Command aliases and shortcuts
- **15-appearance.fish** - Dynamic theme system (see below)
- **20-tools.fish** - Tool integrations (zoxide, fzf, starship, ghostty)
- **99-locals.fish** - Sources git-ignored `secrets.fish` and `local.fish`

When modifying Fish config, edit the appropriate `conf.d/*.fish` file, not
`config.fish`.

### Dynamic Theme System

The appearance system at `/fish/.config/fish/conf.d/15-appearance.fish`
synchronizes themes across all tools:

1. **Detection**: On macOS, checks system appearance via
   `defaults read -g AppleInterfaceStyle`
2. **Rate-limited**: Checks every 5 seconds max to avoid performance impact
3. **Event-driven**: Sets `SYSTEM_APPEARANCE` variable; changes trigger
   `_appearance_change_handler`
4. **Syncs themes for**: bat, git-delta, lazygit, fzf, starship, vivid
   (LS_COLORS)
5. **Catppuccin variants**: Mocha (dark) and Latte (light)

When adding new themed tools, update `_appearance_change_handler` to include
them.

### Intelligent Caching Pattern

The `_config_cache()` function in `/fish/.config/fish/conf.d/02-brew.fish`
caches expensive shell operations:

```fish
_config_cache "$HOME/.config/fish/cache/somefile.fish" 'command to generate content'
```

- Default TTL: 24 hours
- Reduces shell startup time for operations like Homebrew environment setup
- Used for: brew shellenv, vivid-generated LS_COLORS

When adding expensive startup operations, wrap them with `_config_cache`.

### Custom Fish Functions

Located in `/fish/.config/fish/functions/`:

- **ls/ll/la/lt** - Wrappers around `eza` with consistent options
- These override default commands when eza is installed

### Secrets and Local Overrides

Git-ignored files sourced in `99-locals.fish`:

- **secrets.fish** - API keys, tokens, sensitive environment variables
- **local.fish** - Machine-specific overrides

Never commit these files. They're sourced last to override any defaults.

## Package-Specific Details

### Git Configuration

- User identity pre-configured in `/git/.config/git/config`
- Uses git-delta for diff viewing with Catppuccin themes
- Global gitignore in `/git/.config/git/ignore`
- Delta themes imported from `/git/.config/git/delta_themes.inc`

### Ghostty Terminal

- Font: PragmataPro VF Liga at 16pt (requires manual installation)
- 16 color themes in `/ghostty/.config/ghostty/themes/`
- Keybindings include custom Claude Code integration: `super+shift+k`
- Auto theme switching via `GHOSTTY_RESOURCES_DIR` environment variable

### Starship Prompt

- Base config: `/starship/.config/starship.toml`
- Theme variants: `starship_mocha.toml` (dark) and `starship_latte.toml` (light)
- Activated by setting `STARSHIP_CONFIG` environment variable
- Git metrics disabled by default for performance

### Bat (Code Viewer)

- 14 custom color themes in `/bat/.config/bat/themes/`
- Custom syntax definitions in `/bat/.config/bat/syntaxes/`
- Theme set via `BAT_THEME` environment variable

### FZF Integration

- Preview commands use bat (files) and eza (directories)
- Theme opts separated from base opts to allow dynamic switching
- `_FZF_BASE_OPTS` contains layout/UI settings (preserved across theme changes)
- `_FZF_THEME_OPTS` dynamically generated by Catppuccin theme files

## Important Notes

- This repository is macOS-focused but includes Linux fallbacks in appearance
  system
- Non-macOS systems skip appearance checking and use default configs
- The `stow_all.sh` script uses `--restow` to safely update existing symlinks
- Brewfile contains 40+ packages; some are optional (check before running
  `brew bundle`)
- Font files must be installed manually (PragmataPro not in Homebrew)
