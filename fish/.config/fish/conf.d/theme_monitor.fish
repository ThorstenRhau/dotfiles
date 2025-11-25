if not status is-interactive
    exit
end

function _theme_monitor --on-event fish_prompt
    # Only run on macOS
    if not type -q defaults
        return
    end

    # Throttle: Check at most once every 3 seconds to reduce latency
    set -l now (date +%s)
    if set -q _theme_monitor_last_check
        set -l time_since_check (math "$now - $_theme_monitor_last_check")
        if test "$time_since_check" -lt 3
            return
        end
    end
    set -gx _theme_monitor_last_check $now

    set -l val (defaults read -g AppleInterfaceStyle 2>/dev/null)
    if test "$val" = "Dark"
        set val Dark
    else
        set val Light
    end

    # If appearance is not set, or different, update
    if test "$val" != "$appearance"
        source $HOME/.config/fish/themes/set_theme.fish
    end
end