if status is-interactive

    # Initialize fish_user_paths if not already set
    set -q fish_user_paths; or set -x fish_user_paths

    # Function to safely add a directory to PATH
    function safe_add_path
        if test -d $argv[1]
            fish_add_path $argv[1]
        end
    end
    safe_add_path $HOME/bin
    safe_add_path $HOME/.local/bin
    safe_add_path $HOME/.cache/lm-studio/bin
    safe_add_path $HOME/.rd/bin
    safe_add_path $HOME/.docker/bin
    safe_add_path /usr/local/bin

    # Homebrew
    if test -d /opt/homebrew
        set -gx ARCHFLAGS "-arch arm64"
        set -gx HOMEBREW_PREFIX /opt/homebrew
        set -gx HOMEBREW_NO_ANALYTICS 1
        fish_add_path -p /opt/homebrew/sbin
        fish_add_path -p /opt/homebrew/bin
    end

    # Variables
    set -gx fish_greeting # Disable greeting function
    set -gx fish_history_limit 10000
    set -gx GREP_OPTIONS "--color=auto"
    set -gx LC_CTYPE "en_US.UTF-8"
    set -gx LANG "en_US.UTF-8"
    set -gx XDG_CONFIG_HOME "$HOME/.config"

    # Eza (ls replacement)
    if type -q eza
        function ls --wraps eza --description "ls using eza with git info"
            eza --header --git $argv
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
    abbr gc 'git commit'
    abbr gca 'git commit -a'
    abbr gd 'git diff'
    abbr gl 'git pull'
    abbr glg 'git log --oneline --graph --decorate -n 20'
    abbr gp 'git push'
    abbr gpristine 'git reset --hard && git clean --force -dfx'
    abbr gst 'git status'
    abbr pip pip3
    abbr python python3
    function mosh --wraps mosh --description "mosh with 256color support"
        env TERM=xterm-256color command mosh $argv
    end
    function ssh --wraps ssh --description "ssh with 256color support"
        env TERM=xterm-256color command ssh $argv
    end

    # Zoxide
    if type -q zoxide >/dev/null
        zoxide init fish | source
        bind \cz zi
        function cd --wraps=z --description "zoxide directory jumping"
            z $argv
        end
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

    # Themes and appearance

    # macOS check for light/dark appearance
    if type -q defaults
        set -gx appearance (defaults read -g AppleInterfaceStyle 2>/dev/null)
    else
        # Fallback to Dark theme of not on macOS
        set -gx appearance Dark
    end

    # Set fish theme
    if test "$appearance" = Dark
        # Dark theme stuff
        fish_config theme choose tokyonight_night
    else
        # Light theme stuff
        fish_config theme choose tokyonight_day
    end

    # Check if bat exists and set theme, also for the delta pager
    if type -q bat
        set -gx BAT_STYLE changes #Check man-page for further options

        if test "$appearance" = Dark
            set theme tokyonight_night
        else
            set theme tokyonight_day
        end

        set -gx DELTA_THEME "$theme"
        function cat --wraps bat --description "bat with theme and no paging"
            bat --theme="$theme" --paging=never $argv
        end
    end

    # Set fzf theme
    if test "$appearance" = Dark
        source "$HOME/.config/fish/themes/fzf/tokyonight_night.sh"
    else
        source "$HOME/.config/fish/themes/fzf/tokyonight_day.sh"
    end

    # LazyGit
    if type -q lazygit
        abbr lg lazygit
        abbr lgs "lazygit status"
        abbr lgl "lazygit log"

        if test "$appearance" = Dark
            set -gx LG_CONFIG_FILE "$HOME/.config/fish/themes/lazygit/tokyonight_night.yml"
        else
            set -gx LG_CONFIG_FILE "$HOME/.config/fish/themes/lazygit/tokyonight_day.yml"
        end

    end

    # Yazi file manager
    if type -q yazi
        abbr ya yazi
        if not test -d "$HOME/.config/yazi/"
            mkdir -p "$HOME/.config/yazi/"
        end
        if test "$appearance" = Dark
            ln -sf "$HOME/.config/fish/themes/yazi/tokyonight_night.toml" "$HOME/.config/yazi/theme.toml"
        else
            ln -sf "$HOME/.config/fish/themes/yazi/tokyonight_day.toml" "$HOME/.config/yazi/theme.toml"
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
