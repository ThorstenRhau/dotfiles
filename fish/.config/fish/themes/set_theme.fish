# macOS check for light/dark appearance
if type -q defaults
    set -gx appearance (defaults read -g AppleInterfaceStyle 2>/dev/null)
else
    # Fallback to Dark theme of not on macOS
    set -gx appearance Dark
end

# Set fish theme
if test "$appearance" = Dark
    # Dark theme stuff
    fish_config theme choose tokyonight_night
else
    # Light theme stuff
    fish_config theme choose tokyonight_day
end

# Check if bat exists and set theme, also for the delta pager
if type -q bat
    set -gx BAT_STYLE changes #Check man-page for further options

    if test "$appearance" = Dark
        set theme tokyonight_night
    else
        set theme tokyonight_day
    end

    set -gx DELTA_THEME "$theme"
    function cat --wraps bat --description "bat with theme and no paging"
        bat --theme="$theme" --paging=never $argv
    end
end

# Set fzf theme
if test "$appearance" = Dark
    source "$HOME/.config/fish/themes/fzf/tokyonight_night.sh"
else
    source "$HOME/.config/fish/themes/fzf/tokyonight_day.sh"
end

# LazyGit
if type -q lazygit
    abbr lg lazygit
    abbr lgs "lazygit status"
    abbr lgl "lazygit log"

    if test "$appearance" = Dark
        set -gx LG_CONFIG_FILE "$HOME/.config/fish/themes/lazygit/tokyonight_night.yml"
    else
        set -gx LG_CONFIG_FILE "$HOME/.config/fish/themes/lazygit/tokyonight_day.yml"
    end

end
