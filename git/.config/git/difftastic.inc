# Enabled by interactive Zsh when difft is available.
[alias]
  difft = -c core.pager='less -FRX' -c diff.external=difft diff
  dshow = -c core.pager='less -FRX' -c diff.external=difft show --ext-diff
  dlog = -c core.pager='less -FRX' -c diff.external=difft log -p --ext-diff

[difftool]
  prompt = false

[pager]
  difftool = less -FRX

[difftool "difftastic"]
  cmd = difft \"$MERGED\" \"$LOCAL\" abcdef1 100644 \"$REMOTE\" abcdef2 100644
