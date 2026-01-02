function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    if test "$SYSTEM_APPEARANCE" = "dark"
        set -gx BAT_THEME "modus_vivendi_tinted"
        set -gx DELTA_FEATURES "modus-vivendi-tinted"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/modus-vivendi-tinted.yml"
        if test -r "$HOME/.config/fzf/themes/modus_vivendi_tinted.fish"
            source $HOME/.config/fzf/themes/modus_vivendi_tinted.fish
        end
        if type -q vivid
            _config_cache "$HOME/.config/fish/cache/lscolors_modus-vivendi-tinted.fish" 'echo "set -gx LS_COLORS \'"(vivid generate "$HOME/.config/fish/vivid/modus-vivendi-tinted.yml")"\'"'
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_dark.toml"
    else
        set -gx BAT_THEME "modus_operandi_tinted"
        set -gx DELTA_FEATURES "modus-operandi-tinted"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/modus-operandi-tinted.yml"
        if test -r "$HOME/.config/fzf/themes/modus_operandi_tinted.fish"
            source $HOME/.config/fzf/themes/modus_operandi_tinted.fish
        end
        if type -q vivid
            _config_cache "$HOME/.config/fish/cache/lscolors_modus-operandi-tinted.fish" 'echo "set -gx LS_COLORS \'"(vivid generate "$HOME/.config/fish/vivid/modus-operandi-tinted.yml")"\'"'
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
