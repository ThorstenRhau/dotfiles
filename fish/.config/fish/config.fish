# =============================================================================
# OS Detection (must be first - used by functions below)
# =============================================================================

set -g _OS_TYPE (uname)

# =============================================================================
# Homebrew
# =============================================================================

if test -x /opt/homebrew/bin/brew
    _config_cache "$HOME/.config/fish/cache/brew_shellenv.fish" /opt/homebrew/bin/brew shellenv fish

    set -gx ARCHFLAGS "-arch arm64"
    set -gx HOMEBREW_BAT 1
    set -gx HOMEBREW_DOWNLOAD_CONCURRENCY auto
    set -gx HOMEBREW_EDITOR nvim
    set -gx HOMEBREW_NO_ANALYTICS 1
    set -gx HOMEBREW_UPGRADE_GREEDY 1
end

# =============================================================================
# Environment Variables
# =============================================================================

# Global Variables
set -gx CXXFLAGS "-std=gnu++20"
set -gx LANG "en_US.UTF-8"
set -gx LC_CTYPE "en_US.UTF-8"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -g fish_greeting
set -g FISH_CACHE_TTL 86400

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
# Config for interactive fish shells
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

    # Fish syntax highlighting theme (token with auto light/dark switching)
    # Theme is set by _appearance_change_handler based on SYSTEM_APPEARANCE

    # Initialize SYSTEM_APPEARANCE as universal if not set 
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
        _config_cache "$HOME/.config/fish/cache/zoxide_init.fish" zoxide init fish --cmd cd
        bind alt-z cdi
    end

    # Carapace
    if type -q carapace
        set -gx CARAPACE_BRIDGES bash,zsh,fish,inshellisense,cobra
        _config_cache "$HOME/.config/fish/cache/carapace_init.fish" carapace _carapace
    end

    # FZF
    if type -q fzf
        _config_cache "$HOME/.config/fish/cache/fzf_init.fish" fzf --fish

        # Base options (layout, behavior) preserved across theme changes
        set -gx _FZF_BASE_OPTS "\
--height=40% --layout=reverse --info=inline --cycle \
--style=full:sharp --scrollbar='│' \
--prompt='❯ ' --pointer='▶' --marker='✓' \
--ghost='Type to search...' \
--bind='ctrl-/:toggle-preview'"

        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
        set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --exclude .git'

        # Ctrl-T: file finder with bat preview
        set -l preview_cmd "cat {}"
        if type -q bat
            set preview_cmd "bat --style=numbers --color=always --line-range :500 {}"
        end
        set -gx FZF_CTRL_T_OPTS "\
--scheme=path --multi \
--preview '$preview_cmd' \
--preview-window='right:60%:wrap' \
--preview-label=' Preview ' \
--header='ctrl-/ preview, ctrl-a all, ctrl-d none' \
--bind='ctrl-a:select-all,ctrl-d:deselect-all' \
--bind='alt-h:change-preview-window(hidden|right:60%:wrap)'"

        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'

        # Alt-C: directory finder with tree preview
        set -l tree_cmd "tree -C -L 2 {}"
        set -gx FZF_ALT_C_OPTS "\
--scheme=path \
--preview '$tree_cmd' \
--preview-window='right:50%' \
--preview-label=' Directory ' \
--header='ctrl-/ toggle preview'"

        # Ctrl-R: history search (shift-delete to remove entry is built-in)
        set -gx FZF_CTRL_R_OPTS "\
--scheme=history --with-nth=3.. \
--header='⌃Y copy, ⇧fn⌫ delete, ⌥R raw' \
--bind='ctrl-y:execute-silent(echo -n {3..} | pbcopy)+abort'"
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
        _config_cache "$HOME/.config/fish/cache/starship_init.fish" starship init fish
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
