# Modern Mac Setup

[![Lint](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml) [![Maintenance](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/validate-maintenance.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/validate-maintenance.yml) [![Freshness](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/freshness.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/freshness.yml)

A practical, security-conscious path from a new Mac to a small developer setup.

**Supports:** macOS 14 or newer; Apple silicon first, with native Intel support while Homebrew supports it.  
**Last human review:** July 21, 2026

This guide keeps the default install small. Applications, shell changes, and macOS preferences are opt-in.

> Maintainers and coding agents: start with [`AGENTS.md`](AGENTS.md). The README is intentionally for people setting up a Mac.

## 1. Secure the Mac first

Before installing developer tools:

1. Install all macOS updates.
2. Turn on FileVault and the firewall.
3. Set up a backup you can restore from.
4. Save recovery information somewhere other than this Mac.

Use the [security and backup checklist](docs/01-security-and-backups.md) when you need the details.

## 2. Install Apple's tools and clone the guide

```bash
xcode-select --install
```

After the installer finishes:

```bash
git clone https://github.com/jessewalberg/modern-mac-setup.git
cd modern-mac-setup
./scripts/audit.sh
```

The audit is read-only.

## 3. Preview, then install the developer basics

First see exactly what would run:

```bash
./scripts/bootstrap.sh \
  --dry-run \
  --install-homebrew \
  --with-cli \
  --configure-shell
```

Then apply the same setup:

```bash
./scripts/bootstrap.sh \
  --install-homebrew \
  --with-cli \
  --configure-shell
```

The foundation installs four tools:

- `git` for source control;
- `gh` for GitHub;
- `mise` for project-pinned runtimes and developer tools;
- `uv` for Python projects, environments, and tools.

`--with-cli` adds `bat`, `fd`, `fzf`, `jq`, `ripgrep`, `shellcheck`, `shfmt`, and `tree`. Omit that flag for the smallest install. `--configure-shell` adds a managed Homebrew and `mise` block to `~/.zshrc`.

No graphical applications are installed.

Run `./scripts/bootstrap.sh --help` for every option and read [bootstrap details](docs/02-bootstrap.md) only when you need them.

## 4. Add only the applications you choose

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
./scripts/bootstrap.sh --apps Brewfile.apps
```

The example includes alternatives for password managers, browsers, editors, terminals, containers, launchers, and window managers. Uncomment only what belongs on this Mac.

See [applications and preferences](docs/05-apps-and-preferences.md) for permissions and selection guidance.

## 5. Keep runtimes with projects

Use `mise` for Node, Go, Java, Ruby, Terraform, and similar tools. Use `uv` for Python. Declare versions inside each project rather than making this Mac setup repository a hidden source of project requirements.

See [project runtimes](docs/04-runtimes.md) for examples.

## 6. Optionally apply four macOS preferences

Preview the commands:

```bash
./scripts/macos-defaults.sh
```

Apply them:

```bash
./scripts/macos-defaults.sh --apply
```

This shows filename extensions, Finder's path and status bars, and saves screenshots in `~/Pictures/Screenshots`. Previous values are recorded before changes are made.

## Check the result

```bash
./scripts/audit.sh --deep
```

Warnings are prompts to review, not proof that the Mac is unsafe.

## Read more when needed

- [New setup or migration?](docs/migration.md)
- [Git and GitHub authentication](docs/03-git-and-github.md)
- [Maintenance and updates](docs/06-maintenance.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Design principles](docs/design-principles.md)
- [Continuous maintenance policy](MAINTENANCE.md)

## Guardrails

The scripts do not disable macOS security controls, run Homebrew with `sudo`, install Rosetta, grant privacy permissions, write your identity or credentials, remove unrelated software, or install a large personal application stack.

## Contributing

Human contributors should read [`CONTRIBUTING.md`](CONTRIBUTING.md). Coding agents should read [`AGENTS.md`](AGENTS.md) before editing.

MIT licensed. See [`LICENSE`](LICENSE).