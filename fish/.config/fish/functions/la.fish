function la --wraps eza --description "list all using eza"
    if type -q eza
        eza --long --all $_EZA_BASE_OPTS $argv
    else
        command ls -la $argv
    end
end
