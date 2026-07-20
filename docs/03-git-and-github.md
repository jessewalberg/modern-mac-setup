# Git and GitHub

Authentication and authorship are identity decisions, so the bootstrap does not generate keys, choose an email address, or sign in to GitHub.

## Configure authorship

Set a human-readable name and an email appropriate for public commit metadata:

```bash
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR COMMIT EMAIL"
```

A GitHub-provided no-reply address can reduce exposure of a personal mailbox in public commits. Confirm the selected address is verified on the GitHub account before relying on attribution.

Review the effective configuration and its source files:

```bash
git config --global --list --show-origin
git config --list --show-origin
```

Reasonable optional defaults include:

```bash
git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global pull.ff only
git config --global rerere.enabled true
git config --global core.autocrlf input
```

`pull.ff only` is intentionally strict and may not fit every team workflow. Apply it only after understanding how the team handles merge commits and rebases.

## Authenticate with GitHub CLI

Run:

```bash
gh auth login
```

GitHub CLI supports browser-based authentication and can configure Git credentials for HTTPS. Choose between HTTPS and SSH rather than maintaining both accidentally.

Verify:

```bash
gh auth status --hostname github.com
```

Do not paste a personal access token into a Git remote URL, shell script, issue, or dotfile repository.

## SSH option

GitHub's current SSH documentation covers checking existing keys, generating a key, adding it to the macOS keychain-backed agent, uploading the public key, and testing the connection:

- [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Generating a key and adding it to the agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Core rules:

- generate a new key on the new Mac rather than copying a private key casually;
- use a passphrase unless a documented hardware or automation model requires otherwise;
- store only the public key in GitHub;
- never commit the private key;
- use Apple's built-in `ssh-add` for macOS keychain integration;
- test the host fingerprint and connection before trusting automation.

A hardware-backed FIDO security key is a strong option for higher-assurance environments.

## Commit signing

Commit signing is optional and separate from transport authentication. GitHub supports GPG, SSH, and S/MIME signing. Choose one method that the team can operate and recover.

SSH signing can reuse an SSH public key, but authentication and signing keys may be separated to reduce coupling. Signing every commit without a key-rotation and recovery plan can create more friction than assurance.

## Work and personal separation

For multiple identities, avoid repeatedly changing one global email. Use conditional includes based on repository paths:

```ini
# ~/.gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

The included files can define identity, signing keys, and other context-specific settings. Keep secrets out of all Git configuration files.

Continue with [Runtimes](04-runtimes.md).
