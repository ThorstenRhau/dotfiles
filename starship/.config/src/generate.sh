#!/bin/sh
#
# Generate starship theme configs from base + palette files
# Run this after modifying base.toml or palette files

set -eu

script_dir="$(cd "$(dirname "$0")" && pwd)"
out_dir="$(dirname "$script_dir")"
palette_dir="$script_dir/palettes"
appearances='token token-flint token-temper'
modes='dark light'

if [ ! -r "$script_dir/base.toml" ]; then
  printf 'ERROR: missing source: %s\n' "$script_dir/base.toml" >&2
  exit 1
fi

for appearance in $appearances; do
  for mode in $modes; do
    input="$palette_dir/$appearance-$mode.toml"
    if [ ! -r "$input" ]; then
      printf 'ERROR: missing source: %s\n' "$input" >&2
      exit 1
    fi

    palette=$(sed -n '/^palette = /{p;q;}' "$input")
    if [ "$palette" != "palette = \"$appearance\"" ]; then
      printf 'ERROR: invalid palette declaration: %s\n' "$input" >&2
      exit 1
    fi
  done
done

# Base config (no palette, fallback for non-macOS)
cp "$script_dir/base.toml" "$out_dir/starship.toml"

# Remove outputs superseded by the family-aware naming scheme.
for legacy in "$out_dir/starship_dark.toml" "$out_dir/starship_light.toml"; do
  if [ -f "$legacy" ]; then
    rm -f "$legacy"
  fi
done

for appearance in $appearances; do
  for mode in $modes; do
    input="$palette_dir/$appearance-$mode.toml"
    output="$out_dir/starship-$appearance-$mode.toml"
    palette=$(sed -n '/^palette = /{p;q;}' "$input")
    {
      head -1 "$script_dir/base.toml"
      printf '%s\n' "$palette"
      tail -n +2 "$script_dir/base.toml"
      sed -n '/^\[palettes\./,$p' "$input"
    } >"$output"
  done
done

printf 'Generated Starship configs in %s\n' "$out_dir"
