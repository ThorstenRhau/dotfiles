# @fish-lsp-disable-next-line 4007
function _check_appearance_on_prompt --on-event fish_prompt
    if test $_OS_TYPE != Darwin
        return
    end

    # Rate limit: check every 5th prompt
    set -g _appearance_prompt_count (math $_appearance_prompt_count + 1)
    if test $_appearance_prompt_count -lt 3
        return
    end
    set -g _appearance_prompt_count 0

    # Unconditionally set the variable; fish only triggers events if the value actually changes.
    set -l val (defaults read -g AppleInterfaceStyle 2>/dev/null)
    if test "$val" = Dark
        set -Ux SYSTEM_APPEARANCE dark
    else
        set -Ux SYSTEM_APPEARANCE light
    end
end
