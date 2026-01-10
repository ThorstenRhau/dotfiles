---
name: nvim-autocmd
description: Create new autocommands or user commands.
TRIGGER: add autocmd, add autocommand, create command, user command, automation
---

# Autocommand and User Command Configuration

Add autocommands and user commands in `lua/config/autocmds.lua`.

## Location

All autocommands and user commands go in `lua/config/autocmds.lua`.

## Autocommand Pattern

### Basic Structure

```lua
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd('EventName', {
  group = augroup('group_name', { clear = true }),
  callback = function()
    -- Your code here
  end,
})
```

### With Pattern

```lua
autocmd('EventName', {
  group = augroup('group_name', { clear = true }),
  pattern = { 'pattern1', 'pattern2' },
  callback = function()
    -- Your code here
  end,
})
```

### With Event Data

```lua
autocmd('EventName', {
  group = augroup('group_name', { clear = true }),
  callback = function(event)
    -- event.buf - Buffer number
    -- event.match - Matched pattern
    -- event.file - File name
    vim.bo[event.buf].option = value
  end,
})
```

## Common Events

### Buffer Events

- `BufReadPre` - Before reading buffer
- `BufReadPost` - After reading buffer
- `BufWritePre` - Before writing buffer
- `BufWritePost` - After writing buffer
- `BufEnter` - Entering a buffer
- `BufLeave` - Leaving a buffer
- `BufNewFile` - New file created

### Window Events

- `WinEnter` - Entering a window
- `WinLeave` - Leaving a window
- `VimResized` - Vim window resized

### Insert Events

- `InsertEnter` - Entering insert mode
- `InsertLeave` - Leaving insert mode

### Text Events

- `TextYankPost` - After yanking text
- `TextChanged` - Text changed in normal mode
- `TextChangedI` - Text changed in insert mode

### Filetype Events

- `FileType` - Filetype detected

### Focus Events

- `FocusGained` - Window gained focus
- `FocusLost` - Window lost focus

### LSP Events

- `LspAttach` - LSP client attached
- `LspDetach` - LSP client detached

### Terminal Events

- `TermOpen` - Terminal opened
- `TermClose` - Terminal closed
- `TermEnter` - Entering terminal mode
- `TermLeave` - Leaving terminal mode

### User Events

- `User` - Custom user events (e.g., `User LazyDone`)

## Augroups

Always create augroups with `clear = true` to prevent duplicates:

```lua
group = augroup('group_name', { clear = true })
```

This clears previous autocmds in that group when the config reloads.

## Examples

### Highlight on Yank

```lua
autocmd('TextYankPost', {
  group = augroup('highlight_yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
```

### Restore Cursor Position

```lua
autocmd('BufReadPost', {
  group = augroup('restore_cursor', { clear = true }),
  callback = function(event)
    local exclude_ft = { 'gitcommit', 'gitrebase', 'help' }
    if vim.tbl_contains(exclude_ft, vim.bo[event.buf].filetype) then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
```

### Auto-resize Splits

```lua
autocmd('VimResized', {
  group = augroup('resize_splits', { clear = true }),
  callback = function()
    vim.cmd('tabdo wincmd =')
  end,
})
```

### Close Certain Filetypes with q

```lua
autocmd('FileType', {
  group = augroup('close_with_q', { clear = true }),
  pattern = { 'help', 'qf', 'man', 'notify' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', {
      buffer = event.buf,
      silent = true,
    })
  end,
})
```

### Auto-create Parent Directories

```lua
autocmd('BufWritePre', {
  group = augroup('auto_create_dir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+://') then
      return  -- Skip URLs
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})
```

### Check if File Changed Externally

```lua
autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime', { clear = true }),
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})
```

### Filetype-specific Settings

```lua
autocmd('FileType', {
  group = augroup('gitcommit_settings', { clear = true }),
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.textwidth = 72
    vim.opt_local.colorcolumn = '50,73'
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
})
```

### Format on Save

```lua
autocmd('BufWritePre', {
  group = augroup('format_on_save', { clear = true }),
  pattern = { '*.lua', '*.py' },
  callback = function()
    vim.lsp.buf.format()
  end,
})
```

## User Commands

### Basic User Command

```lua
vim.api.nvim_create_user_command('CommandName', function()
  -- Your code here
end, { desc = 'Command description' })
```

### With Arguments

```lua
vim.api.nvim_create_user_command('CommandName', function(opts)
  -- opts.args - String of arguments
  -- opts.fargs - Table of arguments
  print('Args:', opts.args)
end, {
  desc = 'Command description',
  nargs = '*',  -- Number of arguments: 0, 1, *, +, ?
})
```

### With Range

```lua
vim.api.nvim_create_user_command('CommandName', function(opts)
  -- opts.line1 - Start line
  -- opts.line2 - End line
  print('Range:', opts.line1, opts.line2)
end, {
  desc = 'Command description',
  range = true,
})
```

### With Bang

```lua
vim.api.nvim_create_user_command('CommandName', function(opts)
  -- opts.bang - true if ! was used
  if opts.bang then
    print('With bang!')
  end
end, {
  desc = 'Command description',
  bang = true,
})
```

## User Command Examples

### Trim Whitespace

```lua
vim.api.nvim_create_user_command('TrimWhitespace', function()
  local save_cursor = vim.fn.getpos('.')
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setpos('.', save_cursor)
end, { desc = 'Trim trailing whitespace' })

-- Add keymap
vim.keymap.set('n', '<leader>cw', '<cmd>TrimWhitespace<cr>', {
  desc = 'Trim whitespace',
})
```

### Format Buffer

```lua
vim.api.nvim_create_user_command('Format', function()
  vim.lsp.buf.format()
end, { desc = 'Format buffer with LSP' })
```

### Toggle Line Numbers

```lua
vim.api.nvim_create_user_command('ToggleLineNumbers', function()
  if vim.wo.number then
    vim.wo.number = false
    vim.wo.relativenumber = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end, { desc = 'Toggle line numbers' })
```

## Options Reference

### Autocommand Options

```lua
{
  group = augroup('name', { clear = true }),  -- Augroup
  pattern = { 'pattern' },                    -- File patterns
  callback = function(event) end,             -- Lua callback
  command = 'ExCommand',                      -- Ex command (alternative to callback)
  once = true,                                -- Run only once
  nested = true,                              -- Allow nested autocmds
  buffer = bufnr,                             -- Buffer-local
  desc = 'Description',                       -- Description
}
```

### User Command Options

```lua
{
  desc = 'Description',      -- Command description
  nargs = '*',              -- Number of args: 0, 1, *, +, ?
  range = true,             -- Accepts range
  range = '%',              -- Default range
  count = 1,                -- Default count
  bang = true,              -- Accepts !
  bar = true,               -- Can be followed by |
  register = true,          -- Accepts register
  complete = 'file',        -- Completion type
  force = true,             -- Override existing command
}
```

## Workflow

1. Decide if you need autocmd or user command
2. Add to `lua/config/autocmds.lua`
3. Create augroup with `clear = true` for autocmds
4. Add callback or command logic
5. Add keymap if needed
6. Test the autocmd/command
7. Run `make lint` and `make format` to validate

## Checking Autocmds

- `:autocmd` - List all autocmds
- `:autocmd GroupName` - List autocmds in group
- `:autocmd EventName` - List autocmds for event

## Notes

- Always use augroups with `clear = true` to prevent duplicates
- Use `vim.opt_local` for buffer-local settings in autocmds
- Use `pcall` for operations that might fail
- Check `vim.bo.buftype` to filter special buffers
- Use `event.buf` for buffer number in callbacks
- User commands must start with uppercase letter
- Prefer Lua callbacks over Ex commands for better error handling
