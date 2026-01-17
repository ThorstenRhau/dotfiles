function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    if test "$SYSTEM_APPEARANCE" = "dark"
        fish_config theme choose "Everforest Dark"
        set -gx BAT_THEME "everforest_dark"
        set -gx DELTA_FEATURES "everforest-dark"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/everforest-dark.yml"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/everforest_dark"
        if test -r "$HOME/.config/fzf/themes/everforest_dark.fish"
            source $HOME/.config/fzf/themes/everforest_dark.fish
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_dark.toml"
    else
        fish_config theme choose "Everforest Light"
        set -gx BAT_THEME "everforest_light"
        set -gx DELTA_FEATURES "everforest-light"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/everforest-light.yml"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/everforest_light"
        if test -r "$HOME/.config/fzf/themes/everforest_light.fish"
            source $HOME/.config/fzf/themes/everforest_light.fish
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_light.toml"
    end

    # Construct FZF_DEFAULT_OPTS
    set -gx FZF_DEFAULT_OPTS "$_FZF_BASE_OPTS $_FZF_THEME_OPTS"

    # Force repaint if in interactive mode to update prompt immediately
    if status is-interactive
        commandline -f repaint 2>/dev/null
    end
end
