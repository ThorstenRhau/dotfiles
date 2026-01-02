function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    if test "$SYSTEM_APPEARANCE" = "dark"
        set -gx BAT_THEME "modus_vivendi"
        set -gx DELTA_FEATURES "modus-vivendi"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/modus-vivendi.yml"
        if test -r "$HOME/.config/fzf/themes/modus_vivendi.fish"
            source $HOME/.config/fzf/themes/modus_vivendi.fish
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_dark.toml"
    else
        set -gx BAT_THEME "modus_operandi"
        set -gx DELTA_FEATURES "modus-operandi"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/modus-operandi.yml"
        if test -r "$HOME/.config/fzf/themes/modus_operandi.fish"
            source $HOME/.config/fzf/themes/modus_operandi.fish
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
