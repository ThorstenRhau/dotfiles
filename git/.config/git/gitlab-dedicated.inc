[user]
  name = Thorsten Rhau
  email = thorsten.rhau@ericsson.com
  signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANeFj4V6kUwtTW2gAMbH0diZO8MyaQ4kNQ0+f0cVidx

[gpg]
  format = ssh

[gpg "ssh"]
  program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  allowedSignersFile = ~/.config/git/allowed_signers

[commit]
  gpgsign = true
