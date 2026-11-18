# Signing profile for a host with its own key file, such as mighty.home.
# Enable it from the untracked ~/.gitconfig; see Identity and signing in
# docs/configuration-architecture.md. Git's default ssh-keygen signs with the
# file and needs no agent.
[user]
  signingkey = ~/.ssh/id_ed25519.pub

[commit]
  gpgsign = true

[tag]
  gpgSign = true
