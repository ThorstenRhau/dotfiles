function gpristine --description "Reset tracked changes and remove untracked files after confirmation"
    if test (count $argv) -gt 1
        echo "usage: gpristine [--force]" >&2
        return 2
    end

    if test (count $argv) -eq 1
        if test "$argv[1]" != --force
            echo "usage: gpristine [--force]" >&2
            return 2
        end

        git reset --hard; and git clean --force -dfx
        return
    end

    echo "This will discard all uncommitted changes and remove ignored/untracked files." >&2
    read --prompt-str "Type 'gpristine' to continue: " reply
    if test "$reply" != gpristine
        echo "Aborted." >&2
        return 1
    end

    git reset --hard; and git clean --force -dfx
end
