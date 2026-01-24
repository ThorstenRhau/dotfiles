#!/usr/bin/env bash
set -euo pipefail

cat | jq -r '
  # Format duration: ms → "Xm" or "XhYm"
  def format_duration:
    (. / 1000 | floor) as $secs |
    ($secs / 60 | floor) as $mins |
    ($mins / 60 | floor) as $hours |
    ($mins % 60) as $rem_mins |
    if $hours > 0 then "\($hours)h\($rem_mins)m"
    elif $mins > 0 then "\($mins)m"
    else "\($secs)s"
    end;

  "\(.model.display_name) · \(.workspace.project_dir | split("/") | last) · \(.context_window.used_percentage // 0 | floor)% · \((.cost.total_duration_ms // 0) | format_duration) · $\(.cost.total_cost_usd // 0 | . * 100 | floor / 100)"
'
