if status is-interactive
    # Bat (cat replacement)
    if type -q bat
        abbr cat 'bat'
    end

    # Neovim Abbreviations
    if type -q nvim >/dev/null
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
    
    # Utility Abbreviations
    abbr lg 'lazygit'
    abbr pip pip3
    abbr python python3
end
