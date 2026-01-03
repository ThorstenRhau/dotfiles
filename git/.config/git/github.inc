[user]
  name = Thorsten Rhau
  email = thorsten@rhau.se
  signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCNHqQNnQJBvbs/lWJZufbQ7JlF9YtdS2Pw4w72+iZ1

[gpg]
  format = ssh

[gpg "ssh"]
  program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  allowedSignersFile = ~/.config/git/allowed_signers

[commit]
  gpgsign = true
