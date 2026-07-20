# Applications and Preferences

Application choice is where setup guides become stale and overly personal. This repository therefore provides categories and review criteria rather than a mandatory application collection.

## Review each application

Before adding a cask, answer:

1. What recurring task does the application solve?
2. Is a built-in macOS tool already sufficient?
3. Who publishes and signs it?
4. How does it update, and does Homebrew remain the correct update owner?
5. What Accessibility, Full Disk Access, Screen Recording, Input Monitoring, network, kernel/system extension, or login-item permissions does it request?
6. What data leaves the Mac?
7. Does the license permit personal and commercial use?
8. Is it native to Apple silicon, universal, or dependent on Rosetta?
9. How will its configuration and data be backed up or reproduced?
10. What is the removal path?

An application that cannot pass this review should not enter an automated install list.

## Build an application Brewfile

Start from the commented example:

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
```

Uncomment one choice per category where alternatives conflict. Then inspect and apply:

```bash
cat Brewfile.apps
./scripts/bootstrap.sh --apps Brewfile.apps
```

A separate private Brewfile can hold work-specific VPN, security, communication, or licensed applications. Keep credentials and activation material outside every Brewfile.

## App Store applications

The `mas` command can automate Mac App Store installations after the user signs in. It is commented out because App Store identifiers, regional availability, account ownership, and licensing can make public automation brittle.

Record App Store applications only after confirming the numeric identifier with the signed-in account. Never automate Apple-account passwords or multi-factor authentication.

## Terminal and shell

Terminal.app and the default zsh are sufficient for bootstrapping. Add another terminal or shell framework only for a concrete requirement.

Heavy shell frameworks can obscure startup cost, aliases, completion behavior, and security-sensitive hooks. Start with the small managed snippet in `snippets/zshrc`, then add one understood change at a time.

## Dotfiles

Once the shell, Git, editor, and application configuration grows, use a dotfile manager such as chezmoi or a carefully designed bare Git repository. A dotfile workflow should support:

- templates for work and personal machines;
- encrypted or external secret retrieval rather than committed plaintext;
- backups before replacement;
- explicit handling of machine-local files;
- reviewable diffs;
- a bootstrap path that does not require the secrets it is trying to restore.

Do not symlink an unknown person's entire home-directory configuration into a new Mac.

## Narrow macOS defaults

Most `defaults write` recipes are undocumented implementation details and can change between macOS versions. Many are personal taste presented as optimization.

This repository automates only four settings with clear value and low coupling:

```bash
./scripts/macos-defaults.sh          # preview
./scripts/macos-defaults.sh --apply  # record prior values, then apply
```

The script does not restore full preference domains automatically because importing an old domain snapshot could overwrite unrelated later settings. It records each prior key under:

```text
~/.local/state/modern-mac-setup/defaults/TIMESTAMP/
```

Use those records to restore the old value with a matching typed `defaults write`, or delete a key that was previously absent. Log out or restart affected applications when a value does not refresh immediately.

## Preferences that remain manual

Keep these manual because they depend on hardware, accessibility, or personal workflow:

- trackpad and mouse behavior;
- keyboard repeat and remapping;
- display scaling, color, HDR, and Night Shift;
- notification permissions;
- Focus modes;
- Dock layout and auto-hide;
- hot corners and Mission Control;
- sound input and output;
- dictation and Siri;
- iCloud synchronization categories;
- browser extensions;
- Accessibility and Full Disk Access grants.

Continue with [Maintenance](06-maintenance.md).
