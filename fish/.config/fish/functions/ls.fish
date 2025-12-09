function ls --wraps eza --description "ls using eza"
    if type -q eza
        eza $_EZA_BASE_OPTS $argv
    else
        command ls $argv
    end
end
