if status is-login; or status is-interactive

    # Add directories to PATH
    fish_add_path $HOME/bin
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/.cache/lm-studio/bin
    fish_add_path $HOME/.rd/bin
    fish_add_path $HOME/.docker/bin
    fish_add_path /usr/local/bin

    # Homebrew
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv fish)
        set -gx ARCHFLAGS "-arch arm64"
        set -gx HOMEBREW_PREFIX /opt/homebrew
        set -gx HOMEBREW_NO_ANALYTICS 1
        set -gx HOMEBREW_BAT 1
        set -gx HOMEBREW_EDITOR nvim
        set -gx HOMEBREW_DOWNLOAD_CONCURRENCY "auto"
    end

    # Variables
    set -gx CXXFLAGS "-std=gnu++20"
    set -gx LANG "en_US.UTF-8"
    set -gx LC_CTYPE "en_US.UTF-8"
    set -gx XDG_CONFIG_HOME "$HOME/.config"
    set -gx fish_greeting


    # Eza (ls replacement)
    if type -q eza
        set -gx _EZA_BASE_OPTS --header --git --group-directories-first --time-style=long-iso

        function ls --wraps eza --description "ls using eza"
            eza $_EZA_BASE_OPTS $argv
        end

        function ll --wraps eza --description "long list using eza"
            eza --long $_EZA_BASE_OPTS $argv
        end

        function la --wraps eza --description "list all using eza"
            eza --long --all $_EZA_BASE_OPTS $argv
        end

        function lt --wraps eza --description "tree view using eza"
            eza --tree $_EZA_BASE_OPTS $argv
        end
    end

    # Bat (cat replacement)
    if type -q bat
        abbr --add cat 'bat'
    end

    # Neovim
    if type -q nvim >/dev/null
        abbr nv nvim
        set -gx EDITOR (which nvim)
        set -gx VISUAL $EDITOR
        set -gx SUDO_EDITOR $EDITOR
        set -gx MANPAGER "nvim +Man! -"
    end

    # Abbreviations and aliases
    abbr --add gc 'git commit'
    abbr --add gca 'git commit -a'
    abbr --add gd 'git diff'
    abbr --add gl 'git pull'
    abbr --add glg 'git log --oneline --graph --decorate -n 20'
    abbr --add gp 'git push'
    abbr --add gpristine 'git reset --hard && git clean --force -dfx'
    abbr --add gst 'git status'
    abbr --add lg 'lazygit'
    abbr --add pip pip3
    abbr --add python python3

    # Zoxide
    if type -q zoxide >/dev/null
        zoxide init fish --cmd cd | source
        bind \ez cdi
    end

    # FZF
    if type -q fzf >/dev/null
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

    # Sourcing local files
    set secrets_file "$HOME/.config/fish/secrets.fish"
    if test -r $secrets_file
        source $secrets_file
    end

    set local_file "$HOME/.config/fish/local.fish"
    if test -r $local_file
        source $local_file
    end

    # Starship
    starship init fish | source

end
