# Signing profile for a Mac with 1Password. Enable it from the untracked
# ~/.gitconfig; see the Git signing section in AGENTS.md.
[user]
  signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCNHqQNnQJBvbs/lWJZufbQ7JlF9YtdS2Pw4w72+iZ1

[gpg "ssh"]
  program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

[commit]
  gpgsign = true

[tag]
  gpgSign = true
