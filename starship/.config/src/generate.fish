#!/usr/bin/env fish
#
# Generate starship theme configs from base + palette files
# Run this after modifying base.toml or palette files

set -l script_dir (dirname (status filename))
set -l out_dir (dirname $script_dir)

# Base config (no palette - fallback for non-macOS)
cp $script_dir/base.toml $out_dir/starship.toml

# Mocha (dark theme)
cat $script_dir/base.toml $script_dir/palette_mocha.toml > $out_dir/starship_mocha.toml

# Latte (light theme)
cat $script_dir/base.toml $script_dir/palette_latte.toml > $out_dir/starship_latte.toml

echo "Generated starship configs in $out_dir"
