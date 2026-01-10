# =============================================================================
# OS Detection (must be first - used by functions below)
# =============================================================================

set -g _OS_TYPE (uname)

# =============================================================================
# Homebrew
# =============================================================================

if test -x /opt/homebrew/bin/brew
    _config_cache "$HOME/.config/fish/cache/brew_shellenv.fish" "/opt/homebrew/bin/brew shellenv fish"

    set -gx ARCHFLAGS "-arch arm64"
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_NO_ANALYTICS 1
    set -gx HOMEBREW_BAT 1
    set -gx HOMEBREW_EDITOR nvim
    set -gx HOMEBREW_DOWNLOAD_CONCURRENCY auto
end

# =============================================================================
# Environment Variables
# =============================================================================

# Global Variables
set -gx CXXFLAGS "-std=gnu++20"
set -gx LANG "en_US.UTF-8"
set -gx LC_CTYPE "en_US.UTF-8"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx fish_greeting
set -gx FISH_CACHE_TTL 86400

# =============================================================================
# PATH
# =============================================================================

# Add directories to PATH
fish_add_path $HOME/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cache/lm-studio/bin
fish_add_path $HOME/.rd/bin
fish_add_path $HOME/.docker/bin
fish_add_path $HOME/.opencode/bin
fish_add_path /usr/local/bin

# =============================================================================
# Confit for interactive fish shells
# =============================================================================

if status is-interactive
    # Bat (cat replacement)
    if type -q bat
        abbr cat bat
    end

    # Editor setup
    if type -q nvim
        set -gx EDITOR nvim
        set -gx VISUAL $EDITOR
        set -gx SUDO_EDITOR $EDITOR
        set -gx MANPAGER "nvim +Man! -"
        set -gx MANCOLOR true
        abbr nv nvim
    end

    # Git Abbreviations
    abbr gc 'git commit'
    abbr gca 'git commit -a'
    abbr gd 'git diff'
    abbr gl 'git pull'
    abbr glg 'git log --oneline --graph --decorate -n 20'
    abbr gp 'git push'
    abbr gpristine 'git reset --hard && git clean --force -dfx'
    abbr gst 'git status'

    if type -q lazygit
        abbr lg lazygit
    end

    if type -q pip3
        abbr pip pip3
    end

    if type -q python3
        abbr python python3
    end

    # =============================================================================
    # Appearance & Theming
    # =============================================================================

    # Fish syntax highlighting theme (Modus with auto light/dark switching)
    fish_config theme choose Modus

    # Initialize SYSTEM_APPEARANCE as universal if not set (required for neovim to inherit)
    # Universal variables are loaded before config.fish and sync across all sessions
    if not set -q SYSTEM_APPEARANCE
        # @fish-lsp-disable-next-line 2003
        set -Ux SYSTEM_APPEARANCE dark
    end

    # State for rate limiting
    set -g _appearance_last_check 0

    # Load event-based functions (required for --on-event handlers to register)
    functions -q _check_appearance_on_prompt

    # Apply theme immediately on startup (also loads _appearance_change_handler)
    _appearance_change_handler
    # Zoxide
    if type -q zoxide
        zoxide init fish --cmd cd | source
        bind \ez cdi
    end

    # FZF
    if type -q fzf
        fzf --fish | source

        # Base options (layout, info, etc.) to be preserved across theme changes
        set -gx _FZF_BASE_OPTS "--height 40% --layout=reverse --info=inline --border=rounded --prompt='❯ ' --pointer='▶' --marker='✓'"

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
        set -l tree_cmd "tree -C -L 1 {}"
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

# =============================================================================
# Local Configuration
# =============================================================================

# Sourcing local files (Global - secrets might contain env vars)
set -l secrets_file "$HOME/.config/fish/secrets.fish"
if test -r $secrets_file
    source $secrets_file
end

set -l local_file "$HOME/.config/fish/local.fish"
if test -r $local_file
    source $local_file
end
