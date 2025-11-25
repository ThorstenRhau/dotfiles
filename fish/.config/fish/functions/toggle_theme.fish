function toggle_theme --description "Toggle macOS light/dark mode and update fish theme"
    # Toggle macOS appearance
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
    
    # Refresh theme settings
    source $HOME/.config/fish/themes/set_theme.fish
end
