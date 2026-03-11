[user]
  name = Thorsten Rhau
  email = thorsten.rhau@ericsson.com
  signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTP6swt4hv8mX1yxFQjntXGJRDglk/eYfdpb13PPV69

[gpg]
  format = ssh

[gpg "ssh"]
  program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  allowedSignersFile = ~/.config/git/allowed_signers

[commit]
  gpgsign = true
