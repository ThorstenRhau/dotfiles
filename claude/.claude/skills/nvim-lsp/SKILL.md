---
name: nvim-lsp
description: Configure LSP server for a language.
TRIGGER: add lsp, configure lsp, language server, add language support
---

# LSP Server Configuration

Add or configure a language server in `lua/plugins/lsp.lua` using Neovim 0.11+ LSP API.

## LSP Configuration Pattern

The config uses Neovim 0.11+'s native `vim.lsp.config` and `vim.lsp.enable()` APIs:

```lua
-- 1. Define server config
vim.lsp.config.server_name = {
  cmd = { 'server-command', 'args' },
  filetypes = { 'filetype' },
  root_markers = { 'config-file', '.git' },
  capabilities = capabilities,
  settings = {
    -- Server-specific settings
  },
}

-- 2. Enable the server (add to existing vim.lsp.enable call)
vim.lsp.enable({
  'server_name',
  -- ... other servers
})
```

## Adding a New LSP Server

### 1. Add Server to Mason Tool Installer

In the `mason-tool-installer.nvim` spec, add the server to `ensure_installed`:

```lua
{
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  opts = {
    ensure_installed = {
      -- ... existing tools
      'new-language-server',
    },
  },
}
```

Server names use Mason naming (e.g., `rust-analyzer`, `gopls`, `clangd`).

### 2. Configure the Server

In the `nvim-lspconfig` config function, add configuration:

```lua
vim.lsp.config.server_name = {
  cmd = { 'command', '--flag' },
  filetypes = { 'lang' },
  root_markers = { 'project.toml', '.git' },
  capabilities = capabilities,
  settings = {
    serverName = {
      option = value,
    },
  },
}
```

### 3. Enable the Server

Add the server name to the `vim.lsp.enable()` call:

```lua
vim.lsp.enable({
  -- ... existing servers (alphabetical order)
  'new_server',
  -- ... rest of servers
})
```

## Server Configuration Components

### Command

The executable and arguments:

```lua
cmd = { 'server-binary', '--stdio' }
```

Common patterns:
- `{ 'rust-analyzer' }` - No args
- `{ 'vscode-json-language-server', '--stdio' }` - With stdio flag
- `{ 'lua-language-server' }` - Binary name only

### Filetypes

Languages the server handles:

```lua
filetypes = { 'rust' }
filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
```

### Root Markers

Files/directories indicating project root:

```lua
root_markers = { 'Cargo.toml', '.git' }
root_markers = { 'package.json', 'tsconfig.json', '.git' }
```

List in order of specificity (most specific first).

### Capabilities

Always use the shared capabilities (includes blink.cmp):

```lua
capabilities = capabilities
```

This is already defined in the config function.

### Settings

Server-specific configuration:

```lua
settings = {
  rust_analyzer = {
    checkOnSave = { command = 'clippy' },
  },
}
```

Check server documentation for available settings.

## Special Cases

### Schema Support (JSON/YAML)

For JSON/YAML servers, integrate with schemastore:

```lua
-- JSON
vim.lsp.config.jsonls = {
  -- ... other config
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
}

-- YAML
vim.lsp.config.yamlls = {
  -- ... other config
  settings = {
    yaml = {
      schemaStore = { enable = true },
      schemas = {
        ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
      },
      validate = true,
    },
  },
}
```

### Inlay Hints

For TypeScript/Rust and other servers with inlay hints:

```lua
settings = {
  typescript = {
    inlayHints = {
      parameterNames = { enabled = 'all' },
      parameterTypes = { enabled = true },
      variableTypes = { enabled = true },
      functionLikeReturnTypes = { enabled = true },
    },
  },
}
```

### Multiple Servers Per Language

For Python with basedpyright (types) and ruff (lint/format):

```lua
-- Types
vim.lsp.config.basedpyright = {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  -- ...
}

-- Lint/format
vim.lsp.config.ruff = {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  -- ...
}

-- Both enabled
vim.lsp.enable({
  'basedpyright',
  'ruff',
  -- ...
})
```

## Common LSP Servers

| Language | Server | Mason Name | Command |
|----------|--------|------------|---------|
| Rust | rust-analyzer | `rust-analyzer` | `rust-analyzer` |
| Go | gopls | `gopls` | `gopls` |
| C/C++ | clangd | `clangd` | `clangd` |
| Python (types) | Basedpyright | `basedpyright` | `basedpyright-langserver --stdio` |
| Python (lint) | Ruff | `ruff` | `ruff server` |
| TypeScript/JavaScript | vtsls | `vtsls` | `vtsls --stdio` |
| Lua | lua_ls | `lua-language-server` | `lua-language-server` |
| JSON | jsonls | `json-lsp` | `vscode-json-language-server --stdio` |
| YAML | yamlls | `yaml-language-server` | `yaml-language-server --stdio` |
| HTML | html | `html-lsp` | `vscode-html-language-server --stdio` |
| CSS | cssls | `css-lsp` | `vscode-css-language-server --stdio` |
| Bash | bashls | `bash-language-server` | `bash-language-server start` |
| Markdown | marksman | `marksman` | `marksman server` |
| TOML | taplo | `taplo` | `taplo lsp stdio` |

## Workflow

1. Identify the language server for your language
2. Add Mason package name to `ensure_installed` in mason-tool-installer
3. Add `vim.lsp.config.server_name` configuration
4. Add server name to `vim.lsp.enable()` call (alphabetical order)
5. Run `:MasonToolsInstall` to install the server
6. Open a file of that type to test
7. Check `:LspInfo` to verify server attached
8. Run `make lint` and `make format` to validate

## Debugging

- `:LspInfo` - Show attached servers and their status
- `:Mason` - Manage installed tools
- `:MasonToolsInstall` - Install missing tools
- Check `:messages` for LSP errors
- Use `:lua vim.lsp.log.set_level('debug')` for detailed logs (`:lua vim.fn.stdpath('cache') .. '/lsp.log'`)
