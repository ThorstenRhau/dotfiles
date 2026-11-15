#!/bin/sh
#
# Generate starship theme configs from base + palette files
# Run this after modifying base.toml or palette files

set -eu

script_dir=$(
  unset CDPATH
  cd "$(dirname "$0")" && pwd
)
out_dir="$(dirname "$script_dir")"
palette_dir="$script_dir/palettes"
appearances='token token-flint token-temper token-ultra token-meridian token-melange'
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

    if ! grep -qx "\[palettes\.$appearance-$mode\]" "$input"; then
      printf 'ERROR: no [palettes.%s] section in %s\n' "$appearance-$mode" "$input" >&2
      exit 1
    fi
  done
done

# Base config (no palette, fallback for non-macOS)
cp "$script_dir/base.toml" "$out_dir/starship.toml"

for appearance in $appearances; do
  for mode in $modes; do
    input="$palette_dir/$appearance-$mode.toml"
    output="$out_dir/starship-$appearance-$mode.toml"
    {
      head -1 "$script_dir/base.toml"
      printf 'palette = "%s"\n' "$appearance-$mode"
      tail -n +2 "$script_dir/base.toml"
      sed -n '/^\[palettes\./,$p' "$input"
    } >"$output"
  done
done

printf 'Generated Starship configs in %s\n' "$out_dir"
