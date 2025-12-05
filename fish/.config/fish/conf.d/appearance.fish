# Appearance handling configuration

# Handler for variable change
function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test (uname) != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    if test "$SYSTEM_APPEARANCE" = "dark"
        set -gx BAT_THEME "Catppuccin Mocha"
        set -gx DELTA_FEATURES "catppuccin-mocha"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/catppuccin-mocha.yml"
        if test -r "$HOME/.config/fzf/themes/catppuccin_mocha.fish"
            source $HOME/.config/fzf/themes/catppuccin_mocha.fish
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_mocha.toml"
    else
        set -gx BAT_THEME "Catppuccin Latte"
        set -gx DELTA_FEATURES "catppuccin-latte"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/catppuccin-latte.yml"
        if test -r "$HOME/.config/fzf/themes/catppuccin_latte.fish"
            source $HOME/.config/fzf/themes/catppuccin_latte.fish
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_latte.toml"
    end
end

# Initialize if empty (default to dark safely)
if not set -q SYSTEM_APPEARANCE
    set -U SYSTEM_APPEARANCE "dark"
end

# State for rate limiting
set -g _appearance_last_check 0

# Check appearance on prompt (async + rate limited)
function _check_appearance_on_prompt --on-event fish_prompt
    # Check if we are on macOS
    if test (uname) != "Darwin"
        return
    end

    set -l current_time (date +%s)
    set -l time_diff (math "$current_time - $_appearance_last_check")

    # Rate limit: 5 seconds
    if test $time_diff -ge 5
        set -g _appearance_last_check $current_time

        # Run check in background
        # We redirect all output to null to ensure no ghost output on the prompt
        fish -c '
            set -l val (defaults read -g AppleInterfaceStyle 2>/dev/null)
            if test "$val" = "Dark"
                set mode "dark"
            else
                set mode "light"
            end

            if test "$SYSTEM_APPEARANCE" != "$mode"
                set -U SYSTEM_APPEARANCE "$mode"
            end
        ' >/dev/null 2>&1 &
        disown
    end
end

# Apply immediately on startup
_appearance_change_handler
