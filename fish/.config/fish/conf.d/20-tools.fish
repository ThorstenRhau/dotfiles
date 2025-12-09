# Eza configuration (Global)
if type -q eza
    set -gx _EZA_BASE_OPTS --header --git --group-directories-first --time-style=long-iso
end

if status is-interactive
    # Zoxide
    if type -q zoxide
        zoxide init fish --cmd cd | source
        bind \ez cdi
    end

    # FZF
    if type -q fzf
        fzf --fish | source

        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
        set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --exclude .git'

        # Ctrl-T Preview
        set -l preview_cmd "cat {}"
        if type -q bat
            set preview_cmd "bat --style=numbers --color=always --line-range :500 {}"
        end
        set -gx FZF_CTRL_T_OPTS "--preview '$preview_cmd' --preview-window=right:60% --border"

        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'

        # Alt-C Preview
        set -l tree_cmd "ls -al {}"
        if type -q eza
            set tree_cmd "eza --tree --level=1 --color=always --icons=always {}"
        end
        set -gx FZF_ALT_C_OPTS "--preview '$tree_cmd' --preview-window=right:50%"

        set -gx FZF_CTRL_R_OPTS '--height 40% --layout=reverse --info=inline --border=rounded'
        set -gx FZF_TMUX 0
        set -gx FZF_COMPLETION_TRIGGER '**'
    end

    # Ghostty Shell Integration
    if set -q GHOSTTY_RESOURCES_DIR
        set -l ghostty_integration_file "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
        if test -r "$ghostty_integration_file"
            source "$ghostty_integration_file"
        end
    end

    # Starship
    if type -q starship
        starship init fish | source
    end
end
