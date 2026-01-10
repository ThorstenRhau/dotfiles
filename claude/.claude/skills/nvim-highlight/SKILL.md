---
name: nvim-highlight
description: Add custom highlight groups for plugins.
TRIGGER: add highlight, customize theme, theme colors, highlight group
---

# Theme Highlight Customization

Add custom highlight groups for plugins in `lua/plugins/colorscheme.lua`.

## Location

All theme customization is in the modus-themes configuration:

```lua
-- lua/plugins/colorscheme.lua
{
  'miikanissi/modus-themes.nvim',
  config = function()
    require('modus-themes').setup({
      on_highlights = function(highlights, colors)
        -- Add custom highlights here
      end,
    })
  end,
}
```

## Highlight Pattern

### Basic Highlight

```lua
on_highlights = function(highlights, colors)
  highlights.GroupName = { fg = colors.blue, bg = colors.bg_dim }
end
```

### With Attributes

```lua
highlights.GroupName = {
  fg = colors.magenta,
  bg = colors.bg_main,
  bold = true,
  italic = true,
  underline = true,
  strikethrough = true,
  nocombine = true,  -- Don't combine with other highlights
}
```

### Link to Existing Group

```lua
highlights.NewGroup = { link = 'ExistingGroup' }
```

## Available Colors

The `colors` parameter provides these colors:

### Foreground/Background

- `fg_main` - Main foreground
- `fg_dim` - Dimmed foreground
- `bg_main` - Main background (#f5f5f5 light, #141414 dark)
- `bg_dim` - Dimmed background
- `bg_active` - Active element background
- `bg_hl_line` - Highlighted line background

### UI Colors

- `border` - Border color
- `cursor` - Cursor color

### Semantic Colors

Base colors:
- `blue`, `cyan`, `green`, `magenta`, `red`, `yellow`

Variants (warmer/cooler):
- `blue_warmer`, `blue_cooler`
- `cyan_warmer`, `cyan_cooler`
- `green_warmer`, `green_cooler`
- `magenta_warmer`, `magenta_cooler`
- `red_warmer`, `red_cooler`
- `yellow_warmer`, `yellow_cooler`

Intensity variants:
- `blue_faint`, `blue_intense`
- `cyan_faint`, `cyan_intense`
- (and so on for other colors)

## Light/Dark Conditional

Check background color to differentiate light and dark:

```lua
on_highlights = function(highlights, colors)
  if colors.bg_main == '#f5f5f5' then
    -- Light mode specific
    highlights.LineNr = { fg = colors.fg_dim, bg = '#efefef' }
  elseif colors.bg_main == '#141414' then
    -- Dark mode specific
    highlights.LineNr = { fg = colors.fg_dim, bg = '#1a1a1a' }
  end
end
```

## Plugin Highlight Examples

### Indent Guides (indent-blankline)

```lua
highlights.IblIndent = { fg = colors.bg_active, nocombine = true }
highlights.IblScope = { fg = colors.cyan_faint, nocombine = true }
```

### Fuzzy Finder (fzf-lua)

```lua
-- Preview window
highlights.FzfLuaPreviewNormal = { bg = colors.bg_dim }
highlights.FzfLuaPreviewBorder = { fg = colors.border, bg = colors.bg_dim }

-- Match highlighting
highlights.FzfLuaFzfMatch = { fg = colors.magenta, bold = true }
highlights.FzfLuaFzfPointer = { fg = colors.magenta_cooler }
highlights.FzfLuaFzfMarker = { fg = colors.green }

-- Path display
highlights.FzfLuaDirPart = { fg = colors.fg_dim }
highlights.FzfLuaFilePart = { fg = colors.fg_main }
```

### File Explorer (nvim-tree)

```lua
-- Git status
highlights.NvimTreeGitStaged = { fg = colors.green }
highlights.NvimTreeGitRenamed = { fg = colors.magenta }
highlights.NvimTreeGitIgnored = { fg = colors.fg_dim }

-- Folders
highlights.NvimTreeFolderName = { fg = colors.blue }
highlights.NvimTreeOpenedFolderName = { fg = colors.blue, bold = true }
```

### Completion Menu (blink.cmp)

```lua
-- Menu
highlights.BlinkCmpMenu = { bg = colors.bg_dim }
highlights.BlinkCmpMenuBorder = { fg = colors.border, bg = colors.bg_dim }
highlights.BlinkCmpMenuSelection = { bg = colors.bg_active }

-- LSP kinds
highlights.BlinkCmpKindFunction = { fg = colors.magenta }
highlights.BlinkCmpKindVariable = { fg = colors.cyan }
highlights.BlinkCmpKindKeyword = { fg = colors.blue }
```

### Diagnostics (trouble.nvim)

```lua
highlights.TroubleNormal = { bg = colors.bg_dim }
highlights.TroubleDiagnosticsError = { fg = colors.red }
highlights.TroubleDiagnosticsWarn = { fg = colors.yellow }
highlights.TroubleDiagnosticsInfo = { fg = colors.blue }
highlights.TroubleDiagnosticsHint = { fg = colors.cyan }
```

### Git Diff (diffview.nvim)

```lua
highlights.DiffAdd = { bg = colors.bg_added }
highlights.DiffDelete = { bg = colors.bg_removed }
highlights.DiffChange = { bg = colors.bg_changed }
highlights.DiffText = { bg = colors.bg_changed_intense }
```

## Common Highlight Groups

### LSP

- `LspReferenceText` - References to symbol under cursor
- `LspReferenceRead` - Read access to symbol
- `LspReferenceWrite` - Write access to symbol
- `LspSignatureActiveParameter` - Active parameter in signature

### Treesitter

- `@variable` - Variables
- `@function` - Functions
- `@keyword` - Keywords
- `@string` - Strings
- `@comment` - Comments
- `@parameter` - Parameters

### Diagnostics

- `DiagnosticError` - Error diagnostics
- `DiagnosticWarn` - Warning diagnostics
- `DiagnosticInfo` - Info diagnostics
- `DiagnosticHint` - Hint diagnostics

### UI

- `FloatBorder` - Floating window borders
- `NormalFloat` - Floating window background
- `Pmenu` - Popup menu
- `PmenuSel` - Popup menu selection
- `StatusLine` - Status line
- `TabLine` - Tab line

## Finding Highlight Groups

### Under Cursor

```vim
:Inspect
```

Shows highlight group and treesitter info at cursor.

### All Groups

```vim
:so $VIMRUNTIME/syntax/hitest.vim
```

Shows all highlight groups.

### Plugin Groups

Check plugin documentation or source code for highlight group names.

## Workflow

1. Identify plugin highlight groups (`:Inspect`, docs, or source)
2. Add highlights to `on_highlights` function in `colorscheme.lua`
3. Choose appropriate colors from `colors` parameter
4. Test in both light and dark modes if needed
5. Reload config with `:so %` or restart Neovim
6. Run `make lint` and `make format` to validate

## Notes

- Highlights are applied after theme loads
- Use semantic colors (blue, green, etc.) not hex values
- Test in both light and dark modes
- Use `nocombine = true` for subtle elements like indent guides
- Link to existing groups when appropriate for consistency
- Check existing highlights in the file for examples
