#!/bin/sh
#
# Generate starship theme configs from base + palette files
# Run this after modifying base.toml or palette files

script_dir="$(cd "$(dirname "$0")" && pwd)"
out_dir="$(dirname "$script_dir")"

# Base config (no palette, fallback for non-macOS)
cp "$script_dir/base.toml" "$out_dir/starship.toml"

# Dark and light themes
# Extract palette name from palette file, insert after schema line, then append palette definition
for variant in dark light; do
  palette=$(grep '^palette = ' "$script_dir/palette_${variant}.toml" | head -1)
  head -1 "$script_dir/base.toml" > "$out_dir/starship_${variant}.toml"
  printf '%s\n' "$palette" >> "$out_dir/starship_${variant}.toml"
  tail -n +2 "$script_dir/base.toml" >> "$out_dir/starship_${variant}.toml"
  sed -n '/^\[palettes\./,$p' "$script_dir/palette_${variant}.toml" >> "$out_dir/starship_${variant}.toml"
done

printf 'Generated starship configs in %s\n' "$out_dir"
