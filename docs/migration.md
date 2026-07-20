# Migration

A migration should preserve data and intentional configuration without carrying forward obsolete binaries, caches, architecture assumptions, or unexplained privilege.

## Choose the migration boundary

Migration Assistant is appropriate when preserving application state and user accounts is more important than rebuilding from a clean package inventory. A clean setup is appropriate when the old machine has years of drift, an architecture transition, repeated toolchain conflicts, or unclear security state.

A hybrid is often effective:

- migrate documents, photos, mail, and selected application data;
- reinstall applications from current trusted sources;
- rebuild developer tools from reviewed declarations;
- regenerate device-specific credentials;
- restore dotfiles selectively through a managed process.

## Export inventories from the old Mac

Homebrew can produce an inventory for review:

```bash
brew bundle dump --file="$HOME/Desktop/old-mac.Brewfile" --force
```

This is an observation, not the desired state. Review every line and move only justified declarations into the new repository's layered Brewfiles.

Also inventory:

```bash
brew services list
gh auth status --hostname github.com
mise current
uv tool list
```

Do not publish these outputs without checking for usernames, paths, private repository names, internal hosts, or other sensitive metadata.

## Do not copy package-manager internals

Avoid copying:

- `/opt/homebrew`;
- `/usr/local` as a whole;
- Homebrew Cellar paths;
- `~/.cache`, `~/Library/Caches`, or package-manager caches;
- `.venv`, `node_modules`, language build caches, or compiled project artifacts;
- old Docker virtual disks unless a documented recovery requires them;
- an entire `.ssh` directory without reviewing every key and host entry.

Reinstalling from current declarations lets Homebrew select correct bottles and dependencies for the new OS and architecture.

## Credentials

Prefer creating a new SSH key on the new Mac and adding its public key to services. Copying a private key may be justified for a certificate authority, hardware-bound workflow, or continuity requirement, but it should be an explicit security decision with secure transfer and deletion of temporary copies.

Reauthenticate GitHub CLI, cloud CLIs, package registries, VPNs, and enterprise services. Do not migrate opaque credential stores merely to avoid sign-in.

## Validate before retiring the old machine

Before erase or trade-in:

1. compare critical document counts and recent files;
2. open projects and run their tests;
3. confirm repositories have expected remotes and branches;
4. restore a Time Machine file;
5. verify password-manager access and recovery;
6. test hardware tokens and certificates;
7. confirm licensed applications are activated;
8. retain the old machine, encrypted backup, or both through a defined validation period.

Then follow Apple's current erase, Activation Lock, and transfer guidance for the specific ownership model.
