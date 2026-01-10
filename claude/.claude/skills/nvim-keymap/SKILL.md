---
name: nvim-keymap
description: Add or modify keymaps following configuration conventions.
TRIGGER: add keymap, add keybinding, add shortcut, map key
---

# Keymap Configuration

Add or modify keymaps in the Neovim configuration.

## Keymap Locations

### Core Keymaps
General keymaps go in `lua/config/keymaps.lua`:

```lua
local map = vim.keymap.set

map('n', '<leader>key', '<cmd>Command<cr>', { desc = 'Description' })
```

### Plugin Keymaps
Plugin-specific keymaps go in the plugin's spec in `lua/plugins/*.lua`:

```lua
{
  'author/plugin',
  keys = {
    { '<leader>key', '<cmd>PluginCommand<cr>', desc = 'Description' },
  },
}
```

## Keymap Pattern

All keymaps must follow this pattern:

```lua
vim.keymap.set(mode, lhs, rhs, { desc = 'Description' })
```

### Required Components

1. **Mode** - Which mode(s) the keymap applies to
2. **LHS** - The key combination to press
3. **RHS** - The action to perform
4. **desc** - Description (REQUIRED, shows in which-key)

## Modes

Single mode:
```lua
map('n', '<leader>key', action, { desc = 'Action' })  -- Normal mode only
```

Multiple modes:
```lua
map({ 'n', 'v' }, '<leader>key', action, { desc = 'Action' })  -- Normal and Visual
```

Common modes:
- `'n'` - Normal
- `'i'` - Insert
- `'v'` - Visual and Select
- `'x'` - Visual only
- `'s'` - Select
- `'t'` - Terminal
- `'o'` - Operator-pending

## Key Sequences

### Leader Key

The leader key is `<Space>`:

```lua
map('n', '<leader>f', '<cmd>Files<cr>', { desc = 'Find files' })
```

### Special Keys

- `<CR>` - Enter
- `<Esc>` - Escape
- `<Tab>` - Tab
- `<Space>` - Space
- `<BS>` - Backspace
- `<C-x>` - Ctrl+x
- `<A-x>` or `<M-x>` - Alt+x
- `<S-x>` - Shift+x

### Function Keys

- `<F1>` through `<F12>`

## Leader Key Prefixes

Use existing prefixes when possible:

| Prefix | Purpose |
|--------|---------|
| `<leader>f` | file/find operations |
| `<leader>s` | search operations |
| `<leader>g` | git operations |
| `<leader>c` | code actions |
| `<leader>h` | hunk (git) operations |
| `<leader>t` | toggle options |
| `<leader>o` | opencode AI |
| `<leader>a` | claude AI |
| `<leader>q` | project/session |
| `<leader>x` | diagnostics |
| `<leader>b` | buffer management |
| `<leader>w` | window management |

Add new prefix to which-key if needed (in `lua/plugins/ui.lua`).

## Action Types

### Ex Commands

Use `<cmd>command<cr>` format:

```lua
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save file' })
```

### Vim Keybindings

Use raw keybinding:

```lua
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
```

### Functions

Call Lua functions:

```lua
map('n', '<leader>key', function()
  require('plugin').action()
end, { desc = 'Plugin action' })
```

Or use vim.lsp/vim.diagnostic:

```lua
map('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename' })
```

### Expression Mappings

For dynamic behavior:

```lua
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = 'Down' })
```

## Common Options

```lua
{
  desc = 'Description',      -- REQUIRED: Description for which-key
  silent = true,             -- Don't show command in command line
  noremap = true,            -- Default in vim.keymap.set
  expr = true,               -- Treat RHS as expression
  buffer = bufnr,            -- Buffer-local keymap
  nowait = true,             -- Don't wait for more keys
}
```

## Plugin Keymaps

### In Plugin Spec (Lazy Loading)

Best practice - loads plugin when key is pressed:

```lua
{
  'author/plugin',
  keys = {
    { '<leader>key', '<cmd>Command<cr>', desc = 'Description' },
    {
      '<leader>key2',
      function()
        require('plugin').action()
      end,
      desc = 'Description',
      mode = 'n',  -- optional, defaults to 'n'
    },
  },
}
```

### In config/init Function

For keymaps that need plugin to be loaded:

```lua
{
  'author/plugin',
  config = function()
    require('plugin').setup({})

    vim.keymap.set('n', '<leader>key', '<cmd>Command<cr>', { desc = 'Description' })
  end,
}
```

## Which-key Integration

Keymaps automatically appear in which-key if they have `desc`.

Add groups for new prefixes in `lua/plugins/ui.lua`:

```lua
{
  'folke/which-key.nvim',
  opts = {
    spec = {
      { '<leader>n', group = 'new-group' },
    },
  },
}
```

## Examples

### Simple Command

```lua
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save file' })
```

### Multiple Modes

```lua
map({ 'n', 'i', 'x' }, '<C-s>', '<cmd>write<cr><esc>', { desc = 'Save file' })
```

### Function Call

```lua
map('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
```

### Complex Function

```lua
map('n', '<leader>tm', function()
  require('render-markdown').toggle()
end, { desc = 'Toggle markdown render' })
```

### Expression Map

```lua
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = 'Down' })
```

### Visual Mode Paste

```lua
map('x', 'p', '"_dP', { desc = 'Paste without yanking' })
```

### Insert Mode Escape

```lua
map('i', 'jk', '<Esc>', { desc = 'Escape' })
```

### Terminal Mode Navigation

```lua
map('t', '<C-h>', '<C-\\><C-n><C-w>h', { desc = 'Go to left window' })
```

### Buffer-local (LSP)

```lua
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
    end

    map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename')
  end,
})
```

## Workflow

1. Determine appropriate location (core or plugin)
2. Choose appropriate leader prefix (or create new one)
3. Create keymap with required `desc` field
4. Add which-key group if new prefix
5. Test the keymap works
6. Run `make lint` to validate
7. Run `make format` to format with StyLua
8. Check `:map <leader>key` to verify mapping exists
9. Press `<Space>` to see which-key menu

## Checking Existing Keymaps

- `:map` - Show all mappings
- `:nmap` - Show normal mode mappings
- `:imap` - Show insert mode mappings
- `:map <leader>` - Show all leader mappings
- `<Space>` - Open which-key (shows all leader mappings)
- `:Telescope keymaps` or `<leader>sk` - Search keymaps with fzf-lua

## Notes

- Always include `desc` - it's required for which-key
- Use `<cmd>command<cr>` for ex commands (faster than `:command<cr>`)
- Prefer plugin's `keys` property for lazy loading
- Use lowercase for descriptions (consistent style)
- Group related keymaps under the same prefix
