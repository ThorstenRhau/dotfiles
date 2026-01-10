---
name: nvim-treesitter
description: Add new treesitter parser with optional textobjects.
TRIGGER: add parser, add treesitter, add language, treesitter parser
---

# Treesitter Parser Configuration

Add new treesitter parsers for syntax highlighting and textobjects in `lua/plugins/treesitter.lua`.

## Location

All treesitter configuration is in `lua/plugins/treesitter.lua`.

## Adding a Parser

Add the parser name to the `parsers` array:

```lua
local parsers = {
  'bash',
  'css',
  -- ... existing parsers
  'newlang',  -- Add your parser here
  'python',
  -- ... rest of parsers
}
```

**Keep the list alphabetically sorted.**

## Available Parsers

Common parsers:

| Language | Parser Name |
|----------|-------------|
| Bash/Shell | `bash` |
| C | `c` |
| C++ | `cpp` |
| CSS | `css` |
| Diff | `diff` |
| Dockerfile | `dockerfile` |
| Fish | `fish` |
| Git | `git_config`, `git_rebase`, `gitcommit`, `gitignore`, `gitattributes` |
| Go | `go` |
| GraphQL | `graphql` |
| HCL/Terraform | `hcl` |
| HTML | `html` |
| Java | `java` |
| JavaScript | `javascript`, `jsdoc` |
| JSON | `json`, `jsonc` |
| LaTeX | `latex` |
| Lua | `lua` |
| Make | `make` |
| Markdown | `markdown`, `markdown_inline` |
| Python | `python` |
| Regex | `regex` |
| Ruby | `ruby` |
| Rust | `rust` |
| SQL | `sql` |
| TOML | `toml` |
| TypeScript | `typescript`, `tsx` |
| Vim | `vim`, `vimdoc` |
| XML | `xml` |
| YAML | `yaml` |
| Zig | `zig` |

For full list, see: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages

## Installation

After adding parser:

1. Save the file
2. Run `:TSInstall parser-name` to install immediately
3. Or restart Neovim (parsers install automatically on LazyDone)

## Textobjects

Textobjects are already configured for:
- Functions: `af`/`if` (outer/inner)
- Classes: `ac`/`ic` (outer/inner)
- Arguments/Parameters: `aa`/`ia` (outer/inner)

Movement:
- `]f`/`[f` - Next/previous function start
- `]F`/`[F` - Next/previous function end
- `]c`/`[c` - Next/previous class start

These work automatically if the parser supports them.

## Common Textobject Queries

If a parser supports these captures, textobjects work automatically:

- `@function.outer` / `@function.inner` - Function definitions
- `@class.outer` / `@class.inner` - Class definitions
- `@parameter.outer` / `@parameter.inner` - Function parameters
- `@block.outer` / `@block.inner` - Code blocks
- `@conditional.outer` / `@conditional.inner` - If statements
- `@loop.outer` / `@loop.inner` - Loop statements
- `@call.outer` / `@call.inner` - Function calls

## Treesitter Context

The config includes treesitter-context which shows the current context (function/class name) at the top of the window.

Keymap: `[C` - Jump to context

## Checking Parsers

### Installed Parsers

```vim
:TSInstallInfo
```

Shows all available parsers and their installation status.

### Parser at Cursor

```vim
:Inspect
```

Shows treesitter info and highlight groups at cursor position.

### Textobject Captures

```vim
:InspectTree
```

Shows the full treesitter tree for current buffer.

## Integration with Ftplugin

After adding a parser, also create ftplugin file if needed:

```lua
-- after/ftplugin/newlang.lua
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

vim.treesitter.start()

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
```

## Examples

### Add Rust Parser

```lua
local parsers = {
  -- ... existing parsers
  'rust',  -- Add Rust
  -- ... rest
}
```

Then:
- Ftplugin: Create `after/ftplugin/rust.lua`
- LSP: Add rust-analyzer to `lua/plugins/lsp.lua`
- Format: Add rustfmt to `lua/plugins/format.lua`

### Add Go Parser

```lua
local parsers = {
  'go',
  'gomod',  -- go.mod files
  'gowork',  -- go.work files
}
```

### Add Web Parsers

```lua
local parsers = {
  'css',
  'html',
  'javascript',
  'jsdoc',
  'tsx',
  'typescript',
}
```

### Add Config Parsers

```lua
local parsers = {
  'dockerfile',
  'json',
  'jsonc',
  'toml',
  'yaml',
}
```

## Workflow

1. Identify parser name for your language
2. Add to `parsers` array in `treesitter.lua` (alphabetically)
3. Save and run `:TSInstall parser-name` or restart Neovim
4. Create ftplugin file if needed (`/nvim-ftplugin` skill)
5. Test textobjects work (`vif`, `]f`, etc.)
6. Run `make lint` and `make format` to validate

## Notes

- Parsers are installed automatically when Neovim starts (LazyDone event)
- Keep parsers list alphabetically sorted for maintainability
- Most common languages have good textobject support
- Use `:InspectTree` to debug if textobjects don't work
- Treesitter is required for modern features (folding, indent, highlight)
- Some parsers have dependencies (e.g., TSX needs JavaScript)
