function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    if test "$SYSTEM_APPEARANCE" = "dark"
        fish_config theme choose "Rosé Pine Moon"
        set -gx BAT_THEME "rose_pine_moon"
        set -gx DELTA_FEATURES "rose-pine-moon"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/rose-pine-moon.yml"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/rose_pine_moon"
        if test -r "$HOME/.config/fzf/themes/rose_pine_moon.fish"
            source $HOME/.config/fzf/themes/rose_pine_moon.fish
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_dark.toml"
    else
        fish_config theme choose "Rosé Pine Dawn"
        set -gx BAT_THEME "rose_pine_dawn"
        set -gx DELTA_FEATURES "rose-pine-dawn"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/rose-pine-dawn.yml"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/rose_pine_dawn"
        if test -r "$HOME/.config/fzf/themes/rose_pine_dawn.fish"
            source $HOME/.config/fzf/themes/rose_pine_dawn.fish
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
