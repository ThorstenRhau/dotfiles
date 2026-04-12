function _appearance_change_handler --on-variable SYSTEM_APPEARANCE
    if test $_OS_TYPE != "Darwin"
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
        set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
        set -e BAT_THEME
        set -e DELTA_FEATURES
        return
    end

    set -l suffix light
    if test "$SYSTEM_APPEARANCE" = dark
        set suffix dark
    end

    fish_config theme choose token
    set -gx BAT_THEME "token-$suffix"
    set -gx DELTA_FEATURES "token-$suffix"
    set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/token-$suffix.yml"
    set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/themes/token_$suffix"
    if test -r "$HOME/.config/fzf/themes/token_$suffix.fish"
        source "$HOME/.config/fzf/themes/token_$suffix.fish"
    end
    set -gx STARSHIP_CONFIG "$HOME/.config/starship_$suffix.toml"

    # Construct FZF_DEFAULT_OPTS
    set -gx FZF_DEFAULT_OPTS "$_FZF_BASE_OPTS $_FZF_THEME_OPTS"

    # Force repaint if in interactive mode to update prompt immediately
    if status is-interactive
        commandline -f repaint 2>/dev/null
    end
end
