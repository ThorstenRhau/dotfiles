[user]
  name = Thorsten Rhau
  email = thorsten.rhau@ericsson.com
  signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBgVZ3C5euMX2m+xXjpVYhVljTWweim9Y2fxNlCz9Xf1

[gpg]
  format = ssh

[gpg "ssh"]
  program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  allowedSignersFile = ~/.config/git/allowed_signers

[commit]
  gpgsign = true
