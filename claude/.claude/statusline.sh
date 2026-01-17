#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

if ! echo "$input" | jq empty 2>/dev/null; then
  echo "Invalid JSON input" >&2
  exit 1
fi

echo "$input" | jq -r '
  .model.display_name as $model |
  (.workspace.current_dir | split("/") | last) as $dir |
  (
    if .context_window.current_usage and .context_window.context_window_size > 0 then
      (.context_window.current_usage | .input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)
      * 100 / .context_window.context_window_size | floor
    else 0 end
  ) as $pct |
  "λ \($model) | ▶ \($dir) | ∑ \($pct)%"
'
