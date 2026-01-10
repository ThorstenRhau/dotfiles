---
name: nvim-plugin
description: Add or configure Neovim plugin following established patterns.
TRIGGER: add plugin, configure plugin, install plugin, new plugin
---

# Neovim Plugin Management

Add a new plugin or modify existing plugin configuration in the Neovim config.

## Plugin Spec Pattern

All plugins follow this structure in `lua/plugins/*.lua`:

```lua
return {
  {
    'author/plugin-name',
    event = 'VeryLazy',  -- or: cmd, keys, ft, init
    dependencies = { 'other/plugin' },  -- optional
    opts = {
      -- Plugin configuration
    },
  },
}
```

## Key Principles

1. **Use `opts = {}` pattern** - Prefer declarative `opts` over `config = function()`
2. **Lazy loading** - Always specify loading strategy:
   - `event = 'VeryLazy'` - General lazy loading
   - `event = 'InsertEnter'` - Load on insert mode
   - `event = 'BufReadPre'` - Load before reading buffer
   - `cmd = { 'CommandName' }` - Load on command
   - `keys = { ... }` - Load on keymap
   - `ft = { 'markdown' }` - Load on filetype
   - `lazy = false, priority = 1000` - Load immediately (colorschemes only)
3. **All keymaps must have `desc`** - Every keymap needs a description
4. **File organization** - Place plugin in appropriate category file:
   - `editor.lua` - Editing enhancements (autopairs, surround, commenting)
   - `lsp.lua` - Language server protocol
   - `git.lua` - Git integration
   - `picker.lua` - Fuzzy finder
   - `explorer.lua` - File explorers
   - `format.lua` - Formatters and linters
   - `ui.lua` - UI components (statusline, which-key, etc.)
   - `completion.lua` - Completion framework
   - `treesitter.lua` - Treesitter and textobjects
   - `colorscheme.lua` - Theme configuration
   - `terminal.lua` - Terminal integration
   - `session.lua` - Session management
   - `mini.lua` - mini.nvim modules
   - Create new file if none fit

## Plugin Spec Components

### Basic Structure

```lua
{
  'author/plugin-name',
  event = 'VeryLazy',
  opts = {
    option1 = value,
    option2 = value,
  },
}
```

### With Dependencies

```lua
{
  'author/plugin-name',
  dependencies = {
    'dep1/plugin',
    'dep2/plugin',
  },
  opts = {},
}
```

### With Keymaps (in keys property)

```lua
{
  'author/plugin-name',
  keys = {
    { '<leader>key', '<cmd>Command<cr>', desc = 'Description' },
    {
      '<leader>key2',
      function()
        require('plugin').action()
      end,
      desc = 'Description',
      mode = { 'n', 'v' },  -- optional, defaults to 'n'
    },
  },
  opts = {},
}
```

### With Commands

```lua
{
  'author/plugin-name',
  cmd = { 'Command1', 'Command2' },
  opts = {},
}
```

### With Filetype Loading

```lua
{
  'author/plugin-name',
  ft = { 'markdown', 'python' },
  opts = {},
}
```

### With init (for vim.g variables)

```lua
{
  'author/plugin-name',
  event = 'VeryLazy',
  init = function()
    vim.g.plugin_setting = true
  end,
}
```

### Using config (when opts isn't enough)

```lua
{
  'author/plugin-name',
  event = 'VeryLazy',
  config = function()
    require('plugin').setup({
      -- complex configuration
    })
  end,
}
```

## Which-key Groups

If introducing a new leader key prefix, add it to `lua/plugins/ui.lua` in the which-key spec:

```lua
spec = {
  { '<leader>n', group = 'new-group' },
}
```

Existing groups:
- `<leader>f` - file/find
- `<leader>s` - search
- `<leader>g` - git
- `<leader>c` - code
- `<leader>h` - hunk
- `<leader>t` - toggle
- `<leader>o` - opencode
- `<leader>a` - claude
- `<leader>q` - project/session
- `<leader>x` - diagnostics
- `<leader>b` - buffer
- `<leader>w` - window

## Theme Highlights

If the plugin needs custom colors, add highlights to `lua/plugins/colorscheme.lua`:

```lua
on_highlights = function(highlights, colors)
  -- Add plugin highlights
  highlights.PluginHighlight = { fg = colors.blue, bg = colors.bg_dim }
  highlights.PluginHighlightEmphasis = { fg = colors.magenta, bold = true }
end,
```

Available colors: `fg_main`, `bg_main`, `bg_dim`, `bg_active`, `bg_hl_line`, `border`, `cyan`, `magenta`, `blue`, `green`, `yellow`, `red`, `fg_dim`, and variants like `blue_warmer`, `cyan_faint`, etc.

## Workflow

1. Determine appropriate plugin file or create new one
2. Add plugin spec with proper lazy loading
3. Configure using `opts = {}` pattern
4. Add keymaps with `desc` fields
5. Add which-key group if new prefix
6. Add theme highlights if needed
7. Run `:Lazy sync` to install
8. Test the plugin works
9. Run `make lint` to validate Lua
10. Run `make format` to format with StyLua
