# Git and GitHub

Git has two separate concerns in this setup: executable ownership and human identity. The bootstrap validates the executable but deliberately does not invent an identity or sign into an account.

## Git ownership

Apple Command Line Tools provide the bootstrap/default Git:

```bash
xcrun --find git
git --version
```

This Git is sufficient to clone repositories, commit, branch, fetch, push, and perform ordinary development work. It also removes the circular dependency that would result from requiring Homebrew Git before Homebrew exists.

A newer Git can be installed explicitly:

```bash
./scripts/bootstrap.sh --with-homebrew-git
command -v git
git --version
```

The native Homebrew `bin` directory normally takes precedence after `brew shellenv`, so the active executable changes without modifying or deleting Apple's copy. The audit reports the path and runs `--version`; it does not mark a broken executable healthy merely because a file exists.

## Configure authorship

Set a human-readable name and an email appropriate for public commit metadata:

```bash
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR COMMIT EMAIL"
```

A GitHub-provided no-reply address can reduce exposure of a personal mailbox in public commits. Confirm that the selected address is verified on the account before relying on attribution.

Review effective configuration and source files:

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

`pull.ff only` is intentionally strict and may not fit every team. Apply it only after understanding the team's merge and rebase policy.

## Authenticate with GitHub CLI

```bash
gh auth login
```

GitHub CLI supports browser-based authentication and can configure Git credentials for HTTPS. Choose HTTPS or SSH deliberately rather than accumulating both through unrelated setup scripts.

Verify:

```bash
gh auth status --hostname github.com
```

Never paste a personal access token into a Git remote URL, issue, script, or public dotfile repository.

## SSH option

Use GitHub's current documentation:

- [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Generating a key and adding it to the agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Core rules:

- generate a new key on the new Mac rather than casually copying a private key;
- use a passphrase unless a documented hardware or automation model requires otherwise;
- upload only the public key;
- never commit the private key;
- use Apple's built-in `ssh-add` behavior for macOS keychain integration;
- verify the host fingerprint and connection before trusting automation.

A hardware-backed FIDO security key is a strong option for higher-assurance environments.

## Commit signing

Commit signing is optional and separate from transport authentication. GitHub supports GPG, SSH, and S/MIME signing. Choose one method the team can operate, rotate, and recover.

SSH signing can reuse a public key, but authentication and signing keys may be separated to reduce coupling. Signing every commit without a recovery plan can create friction without providing durable assurance.

## Work and personal separation

Avoid repeatedly changing one global email. Use conditional includes based on repository paths:

```ini
# ~/.gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

The included files can define identity, signing keys, and context-specific defaults. Keep secrets out of all Git configuration files.

Continue with [Runtimes](04-runtimes.md).
