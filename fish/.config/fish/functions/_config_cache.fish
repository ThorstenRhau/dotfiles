function _config_cache --argument-names cache_file command_to_run
    # Default TTL to 24 hours if not set
    set -q FISH_CACHE_TTL; or set -l FISH_CACHE_TTL 86400
    set -l refresh_cache 0

    # Ensure cache directory exists
    set -l cache_dir (dirname "$cache_file")
    if not test -d "$cache_dir"
        mkdir -p "$cache_dir"
    end

    if not test -f "$cache_file"
        set refresh_cache 1
    else
        set -l mtime 0
        # Portable stat check
        if string match -q "Darwin" (uname)
            set mtime (stat -f %m "$cache_file" 2>/dev/null; or echo 0)
        else
            set mtime (stat -c %Y "$cache_file" 2>/dev/null; or echo 0)
        end
        
        set -l now (date +%s)
        set -l age (math "$now - $mtime")
        
        if test $age -gt $FISH_CACHE_TTL
            set refresh_cache 1
        end
    end

    if test $refresh_cache -eq 1
        # Execute the command and save output to cache file
        # We use eval to handle pipes or complex commands if passed as a string
        eval "$command_to_run" > "$cache_file"
    end

    # Source the cached file
    source "$cache_file"
end
