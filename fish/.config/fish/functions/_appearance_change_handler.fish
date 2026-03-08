function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    if test "$SYSTEM_APPEARANCE" = "dark"
        fish_config theme choose "Claude Dark"
        set -gx BAT_THEME "claude_dark"
        set -gx DELTA_FEATURES "claude-dark"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/claude-dark.yml"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/claude_dark"
        if test -r "$HOME/.config/fzf/themes/claude_dark.fish"
            source $HOME/.config/fzf/themes/claude_dark.fish
        end
        set -gx STARSHIP_CONFIG "$HOME/.config/starship_dark.toml"
    else
        fish_config theme choose "Claude Light"
        set -gx BAT_THEME "claude_light"
        set -gx DELTA_FEATURES "claude-light"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/claude-light.yml"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/claude_light"
        if test -r "$HOME/.config/fzf/themes/claude_light.fish"
            source $HOME/.config/fzf/themes/claude_light.fish
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
