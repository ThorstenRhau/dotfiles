function ll --wraps eza --description "long list using eza"
    if type -q eza
        eza --long $_EZA_BASE_OPTS $argv
    else
        command ls -l $argv
    end
end
