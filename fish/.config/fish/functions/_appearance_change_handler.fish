function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
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
        if type -q vivid
            _config_cache "$HOME/.config/fish/cache/lscolors_catppuccin-mocha.fish" 'echo "set -gx LS_COLORS \'"(vivid generate catppuccin-mocha)"\'"'
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_mocha.toml"
    else
        set -gx BAT_THEME "Catppuccin Latte"
        set -gx DELTA_FEATURES "catppuccin-latte"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/catppuccin-latte.yml"
        if test -r "$HOME/.config/fzf/themes/catppuccin_latte.fish"
            source $HOME/.config/fzf/themes/catppuccin_latte.fish
        end
        if type -q vivid
            _config_cache "$HOME/.config/fish/cache/lscolors_catppuccin-latte.fish" 'echo "set -gx LS_COLORS \'"(vivid generate catppuccin-latte)"\'"'
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_latte.toml"
    end

    # Construct FZF_DEFAULT_OPTS
    set -gx FZF_DEFAULT_OPTS "$_FZF_BASE_OPTS $_FZF_THEME_OPTS"

    # Force repaint if in interactive mode to update prompt immediately
    if status is-interactive
        commandline -f repaint 2>/dev/null
    end
end
