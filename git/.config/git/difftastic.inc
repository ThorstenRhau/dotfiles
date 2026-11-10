# Enabled by interactive Zsh when difft is available.
[alias]
  difft = -c core.pager='less -FRX' -c diff.external=difft diff
  dshow = -c core.pager='less -FRX' -c diff.external=difft show --ext-diff
  dlog = -c core.pager='less -FRX' -c diff.external=difft log -p --ext-diff

[difftool "difftastic"]
  # Page only this tool. A pager for every difftool would take the terminal
  # away from the Neovim difftool.
  cmd = "if [ -t 1 ]; then \
    difft --color=always \"$MERGED\" \"$LOCAL\" abcdef1 100644 \"$REMOTE\" abcdef2 100644 | less -FRX; \
    else \
    difft \"$MERGED\" \"$LOCAL\" abcdef1 100644 \"$REMOTE\" abcdef2 100644; \
    fi"
