#!/usr/bin/env fish
#
# Generate starship theme configs from base + palette files
# Run this after modifying base.toml or palette files

set -l script_dir (dirname (status filename))
set -l out_dir (dirname $script_dir)

# Base config (no palette - fallback for non-macOS)
cp $script_dir/base.toml $out_dir/starship.toml

# Dark theme
# Insert palette directive after schema line, then append palette definition
head -1 $script_dir/base.toml > $out_dir/starship_dark.toml
echo 'palette = "rose-pine-moon"' >> $out_dir/starship_dark.toml
tail -n +2 $script_dir/base.toml >> $out_dir/starship_dark.toml
grep -A 100 '^\[palettes\.' $script_dir/palette_dark.toml >> $out_dir/starship_dark.toml

# Light theme
head -1 $script_dir/base.toml > $out_dir/starship_light.toml
echo 'palette = "rose-pine-dawn"' >> $out_dir/starship_light.toml
tail -n +2 $script_dir/base.toml >> $out_dir/starship_light.toml
grep -A 100 '^\[palettes\.' $script_dir/palette_light.toml >> $out_dir/starship_light.toml

echo "Generated starship configs in $out_dir"
