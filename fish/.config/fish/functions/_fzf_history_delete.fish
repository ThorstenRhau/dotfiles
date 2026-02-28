function _fzf_history_delete
    # Takes history entries as arguments (formatted as "<timestamp>\t<command>")
    # and deletes the command from history. Used by the fzf-history-widget
    # shift-delete binding to avoid complex inline regex escaping.
    for entry in $argv
        set -l cmd (string split --max 1 \t -- $entry)[2]
        builtin history delete --exact --case-sensitive -- $cmd
    end
end
