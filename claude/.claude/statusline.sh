#!/usr/bin/env bash
set -euo pipefail

# Read JSON input once
input=$(cat)

# Validate JSON input
if ! echo "$input" | jq empty 2>/dev/null; then
  echo "Invalid JSON input" >&2
  exit 1
fi

# Helper functions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_context_window_size() { echo "$input" | jq -r '.context_window.context_window_size'; }

get_context_percent() {
  local usage context_size current_tokens
  usage=$(echo "$input" | jq '.context_window.current_usage')
  if [ "$usage" != "null" ]; then
    context_size=$(get_context_window_size)
    current_tokens=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    if [ "$context_size" -gt 0 ] 2>/dev/null; then
      echo $((current_tokens * 100 / context_size))
    else
      echo "0"
    fi
  else
    echo "0"
  fi
}

get_git_info() {
  local project_dir head_file head_content branch status_parts
  project_dir=$(get_project_dir)
  head_file="$project_dir/.git/HEAD"

  [ ! -f "$head_file" ] && return

  head_content=$(cat "$head_file")

  # Validate head_content is not empty
  [ -z "$head_content" ] && return

  if [[ "$head_content" =~ ^ref:\ refs/heads/(.+)$ ]]; then
    branch="${BASH_REMATCH[1]}"
  elif [[ "$head_content" =~ ^[0-9a-f]{7,40}$ ]]; then
    # Detached HEAD - show short SHA (validated as hex)
    branch="${head_content:0:7}"
  else
    # Unknown format
    return
  fi

  # Get local-only git status (no remote queries)
  status_parts=()

  # Use git -C to run in project dir, --no-optional-locks to avoid lock files
  local staged unstaged untracked
  staged=$(git -C "$project_dir" --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  unstaged=$(git -C "$project_dir" --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$project_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  [ "$staged" -gt 0 ] && status_parts+=("● $staged")
  [ "$unstaged" -gt 0 ] && status_parts+=("○ $unstaged")
  [ "$untracked" -gt 0 ] && status_parts+=("? $untracked")

  if [ ${#status_parts[@]} -gt 0 ]; then
    echo "$branch [${status_parts[*]}]"
  else
    echo "$branch"
  fi
}

# Use the helpers
MODEL=$(get_model_name)
DIR=$(get_current_dir)
CONTEXT_PCT=$(get_context_percent)
GIT_INFO=$(get_git_info)

# Build output
OUTPUT="󱜚  $MODEL |   ${DIR##*/}"
[ -n "$GIT_INFO" ] && OUTPUT+=" |  $GIT_INFO"
OUTPUT+=" |   ${CONTEXT_PCT}%"

echo "$OUTPUT"
