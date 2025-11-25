if not status is-interactive
    exit
end

function _theme_monitor --on-event fish_prompt
    # Only run on macOS
    if not type -q defaults
        return
    end

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
