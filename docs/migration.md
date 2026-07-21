# Migration

A migration should preserve data and deliberate configuration without carrying forward opaque package-manager state, stale credentials, or the wrong CPU architecture.

## Choose the migration boundary

Use Migration Assistant when preserving broad application state is more important than a clean software baseline. Use a clean setup when inherited shell, package, and architecture state is the larger risk.

A practical hybrid is:

- migrate documents and selected application data;
- reinstall developer tools from reviewed declarations;
- regenerate device-specific credentials;
- restore dotfiles through a managed process;
- validate each project from its committed configuration.

## Export inventories from the old Mac

Homebrew can produce an inventory for review:

```bash
brew bundle dump --file="$HOME/Desktop/old-mac.Brewfile" --force
```

This is evidence, not desired state. Review every declaration before moving it into one of this repository's layers.

Also inventory:

```bash
uname -m
brew --prefix
command -v git
git --version
brew services list
gh auth status --hostname github.com
mise current
uv tool list
```

Do not publish these outputs without removing usernames, paths, private repository names, internal hosts, serial numbers, or other sensitive metadata.

## Architecture migration

The supported Homebrew pairings are:

- Apple silicon: `/opt/homebrew`;
- Intel: `/usr/local`.

Do not copy `/usr/local` from an Intel Mac onto Apple silicon, and do not put an Intel Homebrew path ahead of `/opt/homebrew` in a native Apple-silicon shell. The bootstrap deliberately stops when it finds only the other-architecture installation or a conflicting `brew` in `PATH`.

On an Apple-silicon Mac that genuinely needs one legacy Intel tool:

1. document the exact application and why a native replacement is unavailable;
2. keep its execution isolated from the native development shell;
3. avoid global PATH entries that select the Intel prefix;
4. define an owner and retirement date;
5. retest after every macOS or application update.

A second Homebrew installation is not the default solution for one legacy binary.

## Do not copy package-manager internals

Avoid copying:

- `/opt/homebrew`;
- `/usr/local` as a whole;
- Homebrew Cellar paths;
- `~/.cache`, `~/Library/Caches`, or package-manager caches;
- `.venv`, `node_modules`, runtime build caches, or compiled artifacts;
- old container virtual disks unless a documented recovery requires them;
- an entire `.ssh` directory without reviewing every key and host entry.

Reinstallation from current declarations lets Homebrew and runtime managers select the correct artifacts for the new OS and architecture.

## Credentials

Prefer creating a new SSH key on the new Mac and adding its public key to services. Copying a private key may be justified for a certificate-authority or continuity requirement, but it should be an explicit security decision with a secure transfer and deletion plan.

Reauthenticate GitHub CLI, cloud CLIs, package registries, VPNs, and enterprise services. Do not migrate opaque credential stores only to avoid sign-in.

## Validate before retiring the old machine

Before erase or trade-in:

1. compare critical document counts and recent files;
2. open projects and run their tests;
3. confirm repositories have expected remotes and branches;
4. restore at least one backup file;
5. verify password-manager access and recovery;
6. test hardware tokens and certificates;
7. confirm licensed applications are activated;
8. retain the old machine, encrypted backup, or both through a defined validation period.

Then follow Apple's current erase, Activation Lock, and transfer instructions for the ownership model.
