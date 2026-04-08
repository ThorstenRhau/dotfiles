# @fish-lsp-disable-next-line 4007
function _check_appearance_on_prompt --on-event fish_prompt
    # Check if we are on macOS
    if test $_OS_TYPE != Darwin
        return
    end

    set -l current_time (date +%s)
    set -l time_diff (math "$current_time - $_appearance_last_check")

    # Rate limit: 5 seconds
    if test $time_diff -ge 5
        set -g _appearance_last_check $current_time

        # Unconditionally set the variable; fish only triggers events if the value actually changes.
        set -l val (defaults read -g AppleInterfaceStyle 2>/dev/null)
        if test "$val" = Dark
            set -Ux SYSTEM_APPEARANCE dark
        else
            set -Ux SYSTEM_APPEARANCE light
        end
    end
end
