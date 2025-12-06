# Homebrew
if test -x /opt/homebrew/bin/brew
    _config_cache "$HOME/.config/fish/cache/brew_shellenv.fish" "/opt/homebrew/bin/brew shellenv fish"

    set -gx ARCHFLAGS "-arch arm64"
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_NO_ANALYTICS 1
    set -gx HOMEBREW_BAT 1
    set -gx HOMEBREW_EDITOR nvim
    set -gx HOMEBREW_DOWNLOAD_CONCURRENCY "auto"
end
