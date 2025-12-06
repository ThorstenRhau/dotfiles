# Sourcing local files (Global - secrets might contain env vars)
set secrets_file "$HOME/.config/fish/secrets.fish"
if test -r $secrets_file
    source $secrets_file
end

set local_file "$HOME/.config/fish/local.fish"
if test -r $local_file
    source $local_file
end
