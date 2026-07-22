# Modern Mac Setup

[![Lint](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml) [![Maintenance](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/validate-maintenance.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/validate-maintenance.yml) [![Freshness](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/freshness.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/freshness.yml)

A small, maintained path from a new Mac to a useful developer setup.

**Supports:** macOS 14 or newer; Apple silicon first, with native Intel support while Homebrew supports it.  
**Last human review:** July 22, 2026

The default install is deliberately small. Applications, coding agents, shell changes, and macOS preferences are opt-in.

> **Built to stay current:** automation checks packages and workflows, while human reviews replace obsolete advice with current official guidance.
>
> Coding agents and maintainers should read [`AGENTS.md`](AGENTS.md). This README is for the person setting up the Mac.

## Before touching the terminal

1. Install all available macOS updates.
2. Turn on FileVault and the firewall.
3. Configure a backup and restore one representative file.
4. Store recovery information somewhere other than the Mac.
5. Decide whether to migrate data or start clean. Reinstall developer tools from current sources instead of copying Homebrew prefixes and old binaries.

## Install the developer baseline

Install Apple's Command Line Tools:

```bash
xcode-select --install
```

After the installer finishes:

```bash
git clone https://github.com/jessewalberg/modern-mac-setup.git
cd modern-mac-setup
./scripts/audit.sh
```

Preview the setup:

```bash
./scripts/bootstrap.sh \
  --dry-run \
  --install-homebrew \
  --with-cli \
  --configure-shell
```

Apply it:

```bash
./scripts/bootstrap.sh \
  --install-homebrew \
  --with-cli \
  --configure-shell
```

The foundation installs:

- `git` for source control;
- `gh` for GitHub;
- `mise` for project-pinned runtimes and tools;
- `uv` for Python projects and tools.

`--with-cli` adds `bat`, `fd`, `fzf`, `jq`, `ripgrep`, `shellcheck`, `shfmt`, and `tree`. Omit it for the smallest install. No graphical applications are installed.

Run `./scripts/bootstrap.sh --help` for every option.

## Add only the applications you use

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
./scripts/bootstrap.sh --apps Brewfile.apps
```

The example contains commented choices for password managers, browsers, Discord or Slack, editors, coding agents, terminal workspaces such as cmux, containers, launchers, and window managers. Uncomment one option only when it solves a real need.

A browser is enough for occasional community access. Start with one editor or coding agent, learn its permissions and data model, and add another only for a distinct workflow.

## Configure identity and project runtimes

Set Git authorship explicitly, then authenticate through GitHub CLI:

```bash
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR COMMIT EMAIL"
gh auth login
gh auth status --hostname github.com
```

Use `uv` for Python and `mise` for Node, Go, Java, Ruby, Terraform, and similar tools. Declare versions inside each project instead of turning this Mac repository into a hidden global runtime list.

## Optional macOS preferences

The preferences script can show filename extensions, Finder's path and status bars, and save future screenshots in `~/Pictures/Screenshots`.

Preview without changing anything:

```bash
./scripts/macos-defaults.sh
```

Apply after review:

```bash
./scripts/macos-defaults.sh --apply
```

The script records previous raw values and briefly restarts Finder and SystemUIServer. It does not provide one-command restore yet.

## Keep the Mac healthy

Regularly review:

```bash
brew update
brew outdated
mise outdated
./scripts/audit.sh --deep
```

Install macOS security updates, keep browsers and password managers current, review new privacy permissions and login items, push important work, and test a backup restore. Apply Homebrew upgrades deliberately with `brew upgrade`.

A green workflow means the tested path worked at that commit. It is not a security certification.

## Common fixes

| Problem | First step |
| --- | --- |
| Command Line Tools missing | Run `xcode-select --install`, finish the installer, and verify `xcode-select -p` |
| `brew` is not on `PATH` | Load `/opt/homebrew/bin/brew shellenv` on Apple silicon or the `/usr/local` equivalent on Intel |
| Bootstrap reports Rosetta | Relaunch the terminal natively; do not install a second Intel Homebrew |
| GitHub authentication fails | Run `gh auth status --hostname github.com`, then `gh auth login` |
| Runtime tools are missing | Open a new terminal, then run `mise doctor` or `uv tool list` |

Do not fix setup problems with `sudo brew`, `chmod -R 777`, broad ownership changes, disabled security controls, or random versioned Cellar paths.

## Guardrails

The scripts do not disable macOS security controls, run Homebrew as root, install Rosetta, grant privacy permissions, write identity or credentials, sign in to AI providers, enable unattended agents, remove unrelated software, or install a large personal application stack.

## More detail

The single [reference document](docs/REFERENCE.md) contains the deeper security, migration, bootstrap, Git, runtime, application, community, maintenance, and troubleshooting notes.

Human contributors should read [`CONTRIBUTING.md`](CONTRIBUTING.md). Security-sensitive reports should follow [`SECURITY.md`](SECURITY.md). MIT licensed; see [`LICENSE`](LICENSE).
