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
    set -gx fish_history_limit 10000

    # Helper function for system appearance
    function get_appearance
        if test (uname) = "Darwin"
            set -l val (defaults read -g AppleInterfaceStyle 2>/dev/null)
            if test "$val" = "Dark"
                echo "dark"
            else
                echo "light"
            end
        else
            echo "dark" # Default
        end
    end

    # Eza (ls replacement)
    if type -q eza
        function ls --wraps eza --description "ls using eza with git info"
            eza --header --git $argv
        end
    end

    # Bat (cat replacement)
    if type -q bat
        function cat --wraps bat --description "cat using bat"
            bat --binary no-printing --plain  $argv
        end

        if test (get_appearance) = "dark"
            set -gx BAT_THEME "Catppuccin Mocha"
        else
            set -gx BAT_THEME "Catppuccin Latte"
        end
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
    abbr --add pip pip3
    abbr --add python python3

    # Zoxide
    if type -q zoxide >/dev/null
        zoxide init fish --cmd cd | source
        bind \cz zi
    end

    # FZF
    if type -q fzf >/dev/null
        fzf --fish | source
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
        set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --exclude .git'
        set -gx FZF_CTRL_T_OPTS '--preview "bat --style=numbers --color=always {}" --preview-window=right:60% --border'
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
        set -gx FZF_ALT_C_OPTS '--preview "ls -al {}" --preview-window=down:40%'
        set -gx FZF_CTRL_R_OPTS '--height 40% --layout=reverse --info=inline --border=rounded'
        set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --info=inline --border=rounded'
        set -gx FZF_TMUX 0
        set -gx FZF_COMPLETION_TRIGGER '**'
    end

    # Ghostty Shell Integration
    if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
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

    # Set Neovim background based on macOS system appearance
    # 'defaults read' takes ~35ms, so we do it here in the shell start, not inside Neovim.
    if command -q defaults
        if not defaults read -g AppleInterfaceStyle >/dev/null 2>&1
            set -gx NEOVIM_BACKGROUND light
        else
            set -gx NEOVIM_BACKGROUND dark
        end
    end

    # Starship
    if type -q starship
        function starship_transient_prompt_func
            starship module character
        end
        starship init fish | source
        enable_transience
    end

end
