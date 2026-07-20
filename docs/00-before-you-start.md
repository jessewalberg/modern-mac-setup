# Before You Start

A new-Mac setup is primarily a data, identity, and recovery problem. Package installation comes later.

## Decide what “new” means

Choose one path before Setup Assistant:

- **Clean setup:** move documents and selected application data, then reinstall software from known sources.
- **Migration:** use Migration Assistant or a Time Machine backup to carry accounts, applications, settings, and data forward.

A clean setup reduces inherited configuration and architecture problems. Migration is faster and may be the right choice when application state is hard to reconstruct. Neither choice is automatically more secure; the quality of the source machine and backup matters.

See [Migration](migration.md) for a review process that avoids copying Homebrew prefixes or old binaries between architectures.

## Prepare the old machine or existing data source

Before erasing, trading in, or retiring anything:

1. Complete and verify a backup.
2. Open several restored files rather than trusting only a “backup completed” message.
3. Confirm access to the password manager and its recovery material from another device.
4. Confirm access to the primary email account and multi-factor authentication methods.
5. Save license information and deauthorize applications that limit activations.
6. Record repositories with unpushed work and push or archive them deliberately.
7. Export only the package inventories that will be reviewed; do not copy `/opt/homebrew`, `/usr/local`, language runtime directories, caches, or virtual environments.
8. Record VPN, certificate, hardware-token, and corporate-enrollment requirements without committing credentials to this repository.

## During Setup Assistant

Use a strong login password that is not reused elsewhere. Enable the Apple account and Find My only when they fit the ownership and recovery model for the machine. Corporate Macs may have enrollment requirements that supersede this guide.

FileVault may be offered during Setup Assistant. Enable it unless an organization's documented recovery workflow requires a different sequence. Store recovery information somewhere other than the Mac itself.

## Establish a stable operating-system baseline

Before installing developer tooling:

1. Open **System Settings → General → Software Update**.
2. Install the latest patch release offered for the supported macOS version.
3. Restart, then check again until no additional security or compatibility update is pending.
4. Confirm the correct date, time zone, keyboard layout, and language.
5. Confirm the machine is running natively, not from a restored Rosetta-only terminal configuration.

As of July 2026, Apple's current primary macOS release is Tahoe 26. The guide avoids relying on the exact patch number because security releases change frequently.

## Inventory before automation

Create a short list under four headings:

- accounts and identity;
- data and recovery;
- required development stacks;
- applications that are genuinely used.

Anything absent from that list should not be installed merely because it appeared in somebody else's dotfiles or setup article. Every additional package increases update work, permissions, attack surface, and future migration cost.

Continue with [Security and backups](01-security-and-backups.md).
