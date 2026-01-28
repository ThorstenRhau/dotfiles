function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    if test "$SYSTEM_APPEARANCE" = "dark"
        fish_config theme choose "Kanagawa Wave"
        set -gx BAT_THEME "kanagawa_wave"
        set -gx DELTA_FEATURES "kanagawa-wave"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/kanagawa-wave.yml"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/kanagawa_wave"
        if test -r "$HOME/.config/fzf/themes/kanagawa_wave.fish"
            source $HOME/.config/fzf/themes/kanagawa_wave.fish
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_dark.toml"
    else
        fish_config theme choose "Kanagawa Lotus"
        set -gx BAT_THEME "kanagawa_lotus"
        set -gx DELTA_FEATURES "kanagawa-lotus"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/kanagawa-lotus.yml"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/kanagawa_lotus"
        if test -r "$HOME/.config/fzf/themes/kanagawa_lotus.fish"
            source $HOME/.config/fzf/themes/kanagawa_lotus.fish
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
