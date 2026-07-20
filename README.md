# Modern Mac Setup

[![Lint](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml)

A security-conscious, reproducible guide for setting up a new Mac without turning one person's preferences into universal defaults.

**Last reviewed:** July 20, 2026<br>
**Target:** macOS Sonoma 14 or newer, with macOS Tahoe 26 as the current primary release<br>
**Hardware:** Apple silicon first; native Intel execution is supported while Homebrew supports it

This repository starts from first principles:

- Protect data and establish recovery paths before installing developer tools.
- Automate deterministic package installation, not account sign-in, privacy grants, or taste.
- Keep the default install small. Apps, shell changes, and macOS preferences are separate opt-ins.
- Keep language versions inside projects rather than installing one global version of everything.
- Never store tokens, private keys, recovery codes, or machine-specific secrets in this public repository.
- Prefer commands that are inspectable, repeatable, architecture-aware, and safe to rerun.

It is deliberately **not** a giant “run this and replace your whole Mac” script.

## Start here

A new Mac should be prepared in this order:

1. Complete Setup Assistant and decide whether the machine is clean or migrated.
2. Install all available macOS security updates.
3. Configure FileVault, recovery, automatic security updates, the firewall, and a real backup.
4. Install Apple's Command Line Tools.
5. Clone this repository and run the read-only audit.
6. Bootstrap the small developer foundation.
7. Configure GitHub authentication and project-specific runtimes.
8. Add applications only after reviewing their permissions, update model, and license.

The first three steps remain manual by design. Start with:

- [Before you start](docs/00-before-you-start.md)
- [Security and backups](docs/01-security-and-backups.md)

Then install the Command Line Tools:

```bash
xcode-select --install
```

After the installer completes:

```bash
git clone https://github.com/jessewalberg/modern-mac-setup.git
cd modern-mac-setup
./scripts/audit.sh
```

## Bootstrap the developer foundation

Review the files first:

```bash
less scripts/bootstrap.sh
cat Brewfile
cat Brewfile.cli
```

Install Homebrew, the minimal toolset, recommended command-line utilities, and the managed shell snippet:

```bash
./scripts/bootstrap.sh \
  --install-homebrew \
  --with-cli \
  --configure-shell
```

The default `Brewfile` installs only:

- Git
- GitHub CLI
- `mise` for project-pinned non-Python runtimes and tools
- `uv` for Python versions, projects, environments, and Python command-line tools

`Brewfile.cli` is optional and adds small, broadly useful utilities such as `jq`, `ripgrep`, `fd`, `fzf`, `bat`, ShellCheck, and `shfmt`.

The bootstrap uses Homebrew's supported default prefix for the current architecture and fetches the official installer from an immutable, reviewed upstream commit. It refuses to run as root or from a Rosetta-translated terminal, does not use `sudo brew`, does not clean unrelated packages, and installs bundles with `--no-upgrade` to avoid upgrading unrelated software.

See [Bootstrap and package management](docs/02-bootstrap.md) for every flag and trust boundary.

## Add applications deliberately

No graphical applications are installed by default. Copy the example, uncomment only the applications chosen for this Mac, and inspect the result:

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
cat Brewfile.apps
./scripts/bootstrap.sh --apps Brewfile.apps
```

The example groups alternatives so competing tools are not silently installed together. See [Applications and preferences](docs/05-apps-and-preferences.md).

## Optional macOS preferences

The preferences script changes only four narrow, documented settings:

- show filename extensions;
- show Finder's path bar;
- show Finder's status bar;
- save screenshots in `~/Pictures/Screenshots`.

Preview commands without changing anything:

```bash
./scripts/macos-defaults.sh
```

Apply them explicitly:

```bash
./scripts/macos-defaults.sh --apply
```

The script records the previous values before applying changes. It never disables Gatekeeper, System Integrity Protection, quarantine, the firewall, automatic updates, or other security controls.

## Verify the result

Run the read-only audit at any time:

```bash
./scripts/audit.sh
./scripts/audit.sh --deep
```

The deep audit also checks the Brewfiles, GitHub CLI authentication, `mise doctor`, and `brew doctor`. Audit warnings are prompts for review; they are not evidence that a machine is compromised.

## Guide map

| Topic | Document |
| --- | --- |
| Decisions before touching the machine | [Before you start](docs/00-before-you-start.md) |
| FileVault, updates, firewall, permissions, and backup | [Security and backups](docs/01-security-and-backups.md) |
| Homebrew, bundles, bootstrap flags, and shell setup | [Bootstrap](docs/02-bootstrap.md) |
| Identity, authentication, SSH, and commit signing | [Git and GitHub](docs/03-git-and-github.md) |
| Python with `uv`; other runtimes with `mise` | [Runtimes](docs/04-runtimes.md) |
| Choosing apps and applying narrow preferences | [Apps and preferences](docs/05-apps-and-preferences.md) |
| Updates, drift review, and recurring checks | [Maintenance](docs/06-maintenance.md) |
| Clean setup versus migration | [Migration](docs/migration.md) |
| Why the repository is structured this way | [Design principles](docs/design-principles.md) |
| Common failures and safe fixes | [Troubleshooting](docs/troubleshooting.md) |
| Primary documentation used | [References](docs/references.md) |

## What this repository will not do

It will not:

- disable SIP, Gatekeeper, app quarantine, FileVault, or automatic security updates;
- install Homebrew into a nonstandard prefix;
- run Homebrew as root;
- install Rosetta automatically or mix native and translated Homebrew installations;
- generate, copy, upload, or commit SSH private keys;
- write Git identity, email addresses, tokens, or cloud credentials;
- grant Accessibility, Full Disk Access, Screen Recording, or other privacy permissions;
- globally install Python packages with `sudo pip`, or globally install every language runtime;
- remove software merely because it is absent from a Brewfile;
- promise bit-for-bit reproducibility from Homebrew, which is a rolling package manager rather than a lockfile system.

## Updating the setup

Change one layer at a time:

1. Add or remove package declarations in a Brewfile.
2. Review the diff.
3. Run `brew bundle check --no-upgrade`.
4. Apply with `brew bundle install --no-upgrade`.
5. Commit the rationale, not only the package name.

Project runtime versions belong in each project's `mise.toml`, `.tool-versions`, `.python-version`, or equivalent lock/configuration files. The new-Mac repository should not become a hidden source of project requirements.

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md) for the acceptance rules. Security-sensitive reports should follow [SECURITY.md](SECURITY.md). Never paste credentials, private keys, recovery keys, serial numbers, or unredacted diagnostic archives into an issue.

## License

MIT. See [LICENSE](LICENSE).
