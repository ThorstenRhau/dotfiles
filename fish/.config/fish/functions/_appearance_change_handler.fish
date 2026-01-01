function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    if test "$SYSTEM_APPEARANCE" = "dark"
        set -gx BAT_THEME "Melange Dark"
        set -gx DELTA_FEATURES "melange-dark"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/melange-dark.yml"
        if test -r "$HOME/.config/fzf/themes/melange_dark.fish"
            source $HOME/.config/fzf/themes/melange_dark.fish
        end
        if type -q vivid
            _config_cache "$HOME/.config/fish/cache/lscolors_melange-dark.fish" 'echo "set -gx LS_COLORS \'"(vivid generate "$HOME/.config/fish/vivid/melange-dark.yml")"\'"'
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_dark.toml"
    else
        set -gx BAT_THEME "Melange Light"
        set -gx DELTA_FEATURES "melange-light"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/melange-light.yml"
        if test -r "$HOME/.config/fzf/themes/melange_light.fish"
            source $HOME/.config/fzf/themes/melange_light.fish
        end
        if type -q vivid
            _config_cache "$HOME/.config/fish/cache/lscolors_melange-light.fish" 'echo "set -gx LS_COLORS \'"(vivid generate "$HOME/.config/fish/vivid/melange-light.yml")"\'"'
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
