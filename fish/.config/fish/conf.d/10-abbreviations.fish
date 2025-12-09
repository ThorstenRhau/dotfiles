if status is-interactive
    # Bat (cat replacement)
    if type -q bat
        abbr cat 'bat'
    end

    # Neovim Abbreviations
    if type -q nvim
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
    if type -q lazygit
        abbr lg 'lazygit'
    end

    if type -q pip3
        abbr pip pip3
    end

    if type -q python3
        abbr python python3
    end
end
