#!/bin/sh
#
# Generate starship theme configs from base + palette files
# Run this after modifying base.toml or palette files

set -eu

script_dir="$(cd "$(dirname "$0")" && pwd)"
out_dir="$(dirname "$script_dir")"

for input in base.toml palette_dark.toml palette_light.toml; do
  if [ ! -r "$script_dir/$input" ]; then
    printf 'ERROR: missing source: %s\n' "$script_dir/$input" >&2
    exit 1
  fi
done

for variant in dark light; do
  palette=$(sed -n '/^palette = /{p;q;}' "$script_dir/palette_${variant}.toml")
  if [ -z "$palette" ]; then
    printf 'ERROR: missing palette declaration: %s\n' \
      "$script_dir/palette_${variant}.toml" >&2
    exit 1
  fi
done

# Base config (no palette, fallback for non-macOS)
cp "$script_dir/base.toml" "$out_dir/starship.toml"

# Dark and light themes
# Extract palette name from palette file, insert after schema line, then append palette definition
for variant in dark light; do
  palette=$(sed -n '/^palette = /{p;q;}' "$script_dir/palette_${variant}.toml")
  {
    head -1 "$script_dir/base.toml"
    printf '%s\n' "$palette"
    tail -n +2 "$script_dir/base.toml"
    sed -n '/^\[palettes\./,$p' "$script_dir/palette_${variant}.toml"
  } >"$out_dir/starship_${variant}.toml"
done

printf 'Generated starship configs in %s\n' "$out_dir"
