# Everforest Theme Variants

Custom Everforest themes with three contrast levels for both light and dark modes.

## Available Themes

### Dark Mode
- `everforest-dark-hard` - Highest contrast (bg: #272e33)
- `everforest-dark-medium` - Medium contrast (bg: #2d353b) **[Default]**
- `everforest-dark-soft` - Lowest contrast (bg: #333c43)

### Light Mode
- `everforest-light-hard` - Highest contrast (bg: #fffbef)
- `everforest-light-medium` - Medium contrast (bg: #fdf6e3) **[Default]**
- `everforest-light-soft` - Lowest contrast (bg: #f3ead3)

## Usage

To change themes, edit the `theme` line in your `config` file:

```
# Medium contrast (default)
theme = dark:everforest-dark-medium,light:everforest-light-medium

# Hard contrast
theme = dark:everforest-dark-hard,light:everforest-light-hard

# Soft contrast
theme = dark:everforest-dark-soft,light:everforest-light-soft

# Mix and match
theme = dark:everforest-dark-hard,light:everforest-light-soft
```

Themes will automatically switch between dark and light variants based on your system appearance settings.
