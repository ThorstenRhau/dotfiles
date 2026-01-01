#!/usr/bin/env fish
#
# Generate starship theme configs from base + palette files
# Run this after modifying base.toml or palette files

set -l script_dir (dirname (status filename))
set -l out_dir (dirname $script_dir)

# Base config (no palette - fallback for non-macOS)
cp $script_dir/base.toml $out_dir/starship.toml

# Mocha (dark theme)
# Insert palette directive after schema line, then append palette definition
head -1 $script_dir/base.toml > $out_dir/starship_mocha.toml
echo 'palette = "catppuccin_mocha"' >> $out_dir/starship_mocha.toml
tail -n +2 $script_dir/base.toml >> $out_dir/starship_mocha.toml
grep -A 100 '^\[palettes\.' $script_dir/palette_mocha.toml >> $out_dir/starship_mocha.toml

# Latte (light theme)
head -1 $script_dir/base.toml > $out_dir/starship_latte.toml
echo 'palette = "catppuccin_latte"' >> $out_dir/starship_latte.toml
tail -n +2 $script_dir/base.toml >> $out_dir/starship_latte.toml
grep -A 100 '^\[palettes\.' $script_dir/palette_latte.toml >> $out_dir/starship_latte.toml

echo "Generated starship configs in $out_dir"
