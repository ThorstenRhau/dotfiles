function lt --wraps eza --description "tree view using eza"
    if type -q eza
        eza --tree $_EZA_BASE_OPTS $argv
    else
        command ls $argv
    end
end
