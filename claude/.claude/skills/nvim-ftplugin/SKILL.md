---
name: nvim-ftplugin
description: Create or modify filetype-specific settings.
TRIGGER: filetype settings, ftplugin, language settings, add filetype
---

# Filetype Configuration

Create or modify filetype-specific settings in `after/ftplugin/`.

## File Location

Filetype settings go in:
```
after/ftplugin/{filetype}.lua
```

Examples:
- `after/ftplugin/python.lua` - Python settings
- `after/ftplugin/javascript.lua` - JavaScript settings
- `after/ftplugin/markdown.lua` - Markdown settings

## Standard Pattern

All ftplugin files follow this structure:

```lua
-- 1. Set indentation
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

-- 2. Start treesitter
vim.treesitter.start()

-- 3. Set treesitter-based indentation
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

-- 4. Set treesitter-based folding
vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
```

## Indentation Standards

### 2-space indent

Web-related languages and configs:
- JavaScript, TypeScript, JSX, TSX
- HTML, CSS, SCSS
- JSON, YAML
- Lua

```lua
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
```

### 4-space indent

Python and system languages:
- Python
- C, C++, Rust, Go

```lua
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
```

### Use existing indent

Shell scripts and special formats:
- Bash, Fish
- Make (uses tabs)
- Vim script

Usually don't set indentation, or follow language conventions.

## Treesitter Integration

### Enable Treesitter

Always start treesitter for syntax highlighting:

```lua
vim.treesitter.start()
```

### Treesitter Indentation

Use treesitter for smart indentation:

```lua
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
```

### Treesitter Folding

Use treesitter for code folding:

```lua
vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
```

## Special Options

### Text Wrapping (Markdown, Text)

For prose and documentation:

```lua
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2  -- For markdown
```

### Spell Checking

Enable for prose (check buftype to avoid LSP hover windows):

```lua
-- Only for regular files, not scratch buffers
if vim.bo.buftype == '' then
  vim.opt_local.spell = true
end
```

### Text Width

For commit messages or specific formats:

```lua
vim.opt_local.textwidth = 72
```

### Comments

For special comment formats:

```lua
vim.opt_local.commentstring = '# %s'
```

## Example Configurations

### Python

```lua
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4

vim.treesitter.start()

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
```

### JavaScript/TypeScript

```lua
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

vim.treesitter.start()

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
```

### Markdown

```lua
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2

-- Only for regular files, not scratch buffers
if vim.bo.buftype == '' then
  vim.opt_local.spell = true
end

vim.treesitter.start()

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
```

### Rust

```lua
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4

vim.treesitter.start()

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
```

## Option Scopes

### Buffer-local (`vim.bo` or `vim.opt_local`)

Options specific to the buffer:
- `indentexpr` - Indentation expression
- `commentstring` - Comment format
- `textwidth` - Line width
- `buftype` - Buffer type (check for '')

### Window-local (`vim.wo`)

Options specific to the window:
- `foldmethod` - How to fold
- `foldexpr` - Folding expression
- `wrap` - Text wrapping
- `linebreak` - Break at word boundaries
- `conceallevel` - Conceal level
- `spell` - Spell checking

Use `vim.opt_local` for convenience (auto-detects scope).

## Workflow

1. Create file: `after/ftplugin/{filetype}.lua`
2. Set indentation (2 or 4 spaces based on language)
3. Enable treesitter with `vim.treesitter.start()`
4. Set treesitter indentation and folding
5. Add any special options (wrap, spell, etc.)
6. Test by opening a file of that type
7. Run `make lint` to validate
8. Run `make format` to format with StyLua

## Notes

- Ftplugin files are automatically sourced when a file of that type is opened
- Use `vim.opt_local` to ensure settings only affect the current buffer/window
- Always include treesitter integration for consistent highlighting and folding
- Check existing ftplugin files in `after/ftplugin/` for reference
