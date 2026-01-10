---
name: nvim-format
description: Add formatters and linters for languages.
TRIGGER: add formatter, add linter, configure formatting, configure linting
---

# Formatter and Linter Configuration

Add or configure formatters and linters in `lua/plugins/format.lua`.

## Configuration Files

All formatting and linting is configured in `lua/plugins/format.lua`:
- **conform.nvim** - Formatting
- **nvim-lint** - Linting

Tools are installed via mason-tool-installer in `lua/plugins/lsp.lua`.

## Adding a Formatter

### 1. Add to Mason Tool Installer

In `lua/plugins/lsp.lua`, add formatter to `ensure_installed`:

```lua
{
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  opts = {
    ensure_installed = {
      -- ... existing tools
      'new-formatter',
    },
  },
}
```

### 2. Configure in conform.nvim

In `lua/plugins/format.lua`, add to `formatters_by_ft`:

```lua
{
  'stevearc/conform.nvim',
  opts = {
    formatters_by_ft = {
      -- ... existing formatters
      newlang = { 'formatter-name' },
    },
  },
}
```

### 3. Customize Formatter (Optional)

Add custom args in `formatters` table:

```lua
{
  'stevearc/conform.nvim',
  opts = {
    formatters_by_ft = {
      -- ...
    },
    formatters = {
      ['formatter-name'] = {
        prepend_args = { '--flag', 'value' },
      },
    },
  },
}
```

## Adding a Linter

### 1. Add to Mason Tool Installer

In `lua/plugins/lsp.lua`, add linter to `ensure_installed`:

```lua
{
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  opts = {
    ensure_installed = {
      -- ... existing tools
      'new-linter',
    },
  },
}
```

### 2. Configure in nvim-lint

In `lua/plugins/format.lua`, add to `linters_by_ft`:

```lua
config = function()
  local lint = require('lint')

  lint.linters_by_ft = {
    -- ... existing linters
    newlang = { 'linter-name' },
  }

  -- Rest of config...
end
```

### 3. Customize Linter (Optional)

Add custom args:

```lua
lint.linters.yamllint.args = {
  '-d',
  '{extends: default, rules: {line-length: {max: 120}}}',
  '-f',
  'parsable',
  '-',
}
```

## Formatters by Filetype

Current configuration:

| Filetype | Formatter | Mason Package |
|----------|-----------|---------------|
| `lua` | stylua | `stylua` |
| `python` | ruff_format | `ruff` |
| `javascript`, `typescript` | prettier | `prettier` |
| `javascriptreact`, `typescriptreact` | prettier | `prettier` |
| `css`, `scss`, `less` | prettier | `prettier` |
| `html` | prettier | `prettier` |
| `json`, `jsonc` | prettier | `prettier` |
| `yaml` | prettier | `prettier` |
| `markdown` | prettier | `prettier` |
| `bash`, `sh` | shfmt | `shfmt` |
| `fish` | fish_indent | Built-in |
| `toml` | taplo | `taplo` |
| `_` (all) | trim_whitespace | Built-in |

## Linters by Filetype

Current configuration:

| Filetype | Linter | Mason Package |
|----------|--------|---------------|
| `lua` | selene | N/A (install separately) |
| `bash`, `sh` | shellcheck | `shellcheck` |
| `markdown` | markdownlint | `markdownlint` |
| `yaml` | yamllint | `yamllint` |

## Multiple Formatters

Run formatters in sequence:

```lua
formatters_by_ft = {
  python = { 'isort', 'black' },  -- Run isort, then black
}
```

Or specify alternatives (first available):

```lua
formatters_by_ft = {
  javascript = { 'prettierd', 'prettier' },  -- Try prettierd, fallback to prettier
}
```

## Common Formatters

| Language | Formatter | Mason Package | Notes |
|----------|-----------|---------------|-------|
| Lua | stylua | `stylua` | Config in `.stylua.toml` |
| Python | ruff_format | `ruff` | Fast, Rust-based |
| Python | black | `black` | Popular alternative |
| JavaScript/TypeScript | prettier | `prettier` | Universal JS formatter |
| JavaScript/TypeScript | prettierd | `prettierd` | Daemon (faster) |
| Bash/Shell | shfmt | `shfmt` | Shell script formatter |
| Rust | rustfmt | Built-in | Via rustup |
| Go | gofmt/goimports | Built-in | Via go toolchain |
| C/C++ | clang-format | `clang-format` | Style configuration |
| JSON | prettier | `prettier` | Or `jq` |
| YAML | prettier | `prettier` | Or `yamlfmt` |
| TOML | taplo | `taplo` | TOML formatter |
| Markdown | prettier | `prettier` | Or `markdownlint` |
| HTML/CSS | prettier | `prettier` | Universal web formatter |

## Common Linters

| Language | Linter | Mason Package | Notes |
|----------|--------|---------------|-------|
| Lua | selene | N/A | Install separately |
| Python | ruff | `ruff` | Fast, replaces flake8 |
| Python | pylint | `pylint` | Comprehensive |
| JavaScript/TypeScript | eslint | `eslint-lsp` | Via LSP (preferred) |
| Bash/Shell | shellcheck | `shellcheck` | Shell script linter |
| YAML | yamllint | `yamllint` | YAML linter |
| Markdown | markdownlint | `markdownlint` | Markdown linter |
| JSON | jsonlint | `jsonlint` | JSON linter |

## Formatter Options

### Prepend Args

Add arguments before default args:

```lua
formatters = {
  shfmt = {
    prepend_args = { '-i', '2', '-ci' },  -- 2-space indent, case indent
  },
}
```

### Replace Command

Override the command:

```lua
formatters = {
  prettier = {
    command = 'prettierd',
  },
}
```

### Set Stdin

Control stdin behavior:

```lua
formatters = {
  myformatter = {
    stdin = false,  -- Don't use stdin
  },
}
```

## Linter Triggers

Linters run on these events:
- `BufWritePost` - After saving file
- `InsertLeave` - When leaving insert mode
- `BufEnter` - When entering buffer

## Manual Commands

- `:ConformInfo` - Show formatter info for current buffer
- `:lua require('lint').try_lint()` - Run linter manually
- `<leader>cf` - Format current buffer (keymap)

## Examples

### Add Rust Formatter

```lua
-- 1. No Mason package needed (rustfmt via rustup)

-- 2. Add to conform.nvim
formatters_by_ft = {
  rust = { 'rustfmt' },
}
```

### Add ESLint (via LSP)

ESLint is configured as LSP in `lua/plugins/lsp.lua`, not nvim-lint:

```lua
vim.lsp.config.eslint = {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = { 'javascript', 'typescript', ... },
  -- ...
}
```

### Add Black (Python)

```lua
-- 1. Add to mason-tool-installer
ensure_installed = {
  'black',
}

-- 2. Add to conform.nvim
formatters_by_ft = {
  python = { 'black' },  -- Or: { 'isort', 'black' }
}
```

### Add Gofmt (Go)

```lua
-- No Mason package needed (via go toolchain)

formatters_by_ft = {
  go = { 'gofmt' },  -- Or: 'goimports'
}
```

### Customize Prettier

```lua
formatters = {
  prettier = {
    prepend_args = { '--single-quote', '--trailing-comma', 'all' },
  },
}
```

## Workflow

1. Identify formatter/linter for the language
2. Add tool to mason-tool-installer in `lsp.lua`
3. Add filetype mapping to conform/nvim-lint in `format.lua`
4. Customize args if needed
5. Run `:MasonToolsInstall` to install
6. Test with `:ConformInfo` or by formatting
7. Run `make lint` and `make format` to validate config

## Notes

- Formatters run via `<leader>cf` keymap
- Linters run automatically on save and insert leave
- Some formatters are built-in (fish_indent, gofmt)
- Some linters run via LSP (eslint) instead of nvim-lint
- Check Mason for available packages: `:Mason`
- Use LSP for linting when possible (better integration)
