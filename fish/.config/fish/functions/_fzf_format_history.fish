function _fzf_format_history
    # Reads null-separated history entries (<epoch>\t<command>\0) from stdin
    # and replaces the epoch with a human-readable relative timestamp.
    # Output: <formatted>\t<command>\0
    #
    # Format rules:
    #   < 0s ago (clock skew): "    +"
    #   < 72000s (20h):        "HH:MM"
    #   >= 72000s:             "  Xd"
    # Field is 5 chars wide, right-aligned.
    perl -0 -ne '
        chomp;
        my ($epoch, $cmd) = split(/\t/, $_, 2);
        my $now = time();
        my $age = $now - $epoch;
        my $label;
        if ($age < 0) {
            $label = "    +";
        } elsif ($age < 72000) {
            my @t = localtime($epoch);
            $label = sprintf("%02d:%02d", $t[2], $t[1]);
        } else {
            my $days = int($age / 86400);
            $label = sprintf("%4dd", $days);
        }
        print "$label\t$cmd\0";
    '
end
