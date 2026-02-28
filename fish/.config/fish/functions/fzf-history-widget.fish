function fzf-history-widget -d "Show command history"
    # Custom override of fzf's auto-generated fzf-history-widget.
    # Differences from the generated version:
    #   - FZF_DEFAULT_COMMAND pipes through _fzf_format_history to show
    #     human-readable relative timestamps (HH:MM or Xd) instead of epochs
    #   - shift-delete calls _fzf_history_delete to strip the formatted
    #     timestamp before deleting (avoids inline regex escaping)
    #   - preview drops the redundant date conversion line
    set -l -- command_line (commandline)
    set -l -- current_line (commandline -L)
    set -l -- total_lines (count $command_line)
    set -l -- fzf_query (string escape -- $command_line[$current_line])

    set -lx -- FZF_DEFAULT_OPTS (__fzf_defaults '' \
      '--nth=2..,.. --scheme=history --multi --no-multi-line --no-wrap --wrap-sign="\t\t\t↳ " --preview-wrap-sign="↳ "' \
      '--bind=\'shift-delete:execute-silent(for i in (string split0 -- <{+f}); _fzf_history_delete $i; end)+reload(eval $FZF_DEFAULT_COMMAND)\'' \
      '--bind="alt-enter:become(string join0 -- (string collect -- {+2..} | fish_indent -i))"' \
      "--bind=ctrl-r:toggle-sort,alt-r:toggle-raw --highlight-line $FZF_CTRL_R_OPTS" \
      '--accept-nth=2.. --delimiter="\t" --tabstop=4 --read0 --print0 --with-shell='(status fish-path)\\ -c)

    # Add dynamic preview options if preview command isn't already set by user
    if string match -qvr -- '--preview[= ]' "$FZF_DEFAULT_OPTS"
      # Prepend the options to allow user customizations
      set -p -- FZF_DEFAULT_OPTS \
        '--bind="focus,resize:bg-transform:if test \\"$FZF_COLUMNS\\" -gt 100 -a \\\\( \\"$FZF_SELECT_COUNT\\" -gt 0 -o \\\\( -z \\"$FZF_WRAP\\" -a (string length -- {}) -gt (math $FZF_COLUMNS - 4) \\\\) -o (string collect -- {2..} | fish_indent | count) -gt 1 \\\\); echo show-preview; else echo hide-preview; end"' \
        '--preview="string collect -- (test \\"$FZF_SELECT_COUNT\\" -gt 0; and string collect -- {+2..}) \\"\\n\\" {2..} | fish_indent --ansi"' \
        '--preview-window="right,50%,wrap-word,follow,info,hidden"'
    end

    set -lx FZF_DEFAULT_OPTS_FILE

    set -lx -- FZF_DEFAULT_COMMAND 'builtin history -z --show-time="%s%t" | _fzf_format_history'

    # Enable syntax highlighting colors on fish v4.3.3 and newer
    if set -l -- v (string match -r -- '^(\d+)\.(\d+)(?:\.(\d+))?' $version)
    and test "$v[2]" -gt 4 -o "$v[2]" -eq 4 -a \
      \( "$v[3]" -gt 3 -o "$v[3]" -eq 3 -a \
      \( -n "$v[4]" -a "$v[4]" -ge 3 \) \)

      set -a -- FZF_DEFAULT_OPTS '--ansi'
      # Include --color=always before the pipe so fish_indent output is colored
      set -lx -- FZF_DEFAULT_COMMAND 'builtin history -z --show-time="%s%t" --color=always | _fzf_format_history'
    end

    # Merge history from other sessions before searching
    test -z "$fish_private_mode"; and builtin history merge

    if set -l result (eval $FZF_DEFAULT_COMMAND \| (__fzfcmd) --query=$fzf_query | string split0)
      if test "$total_lines" -eq 1
        commandline -- $result
      else
        set -l a (math $current_line - 1)
        set -l b (math $current_line + 1)
        commandline -- $command_line[1..$a] $result
        commandline -a -- '' $command_line[$b..-1]
      end
    end

    commandline -f repaint
end
