# Global Variables
set -gx CXXFLAGS "-std=gnu++20"
set -gx LANG "en_US.UTF-8"
set -gx LC_CTYPE "en_US.UTF-8"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx fish_greeting
set -gx FISH_CACHE_TTL 86400

# Editor setup (Global)
if type -q nvim
    set -gx EDITOR (which nvim)
    set -gx VISUAL $EDITOR
    set -gx SUDO_EDITOR $EDITOR
    set -gx MANPAGER "nvim +Man! -"
end
