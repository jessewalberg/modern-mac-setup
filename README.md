# Modern Mac Setup

[![Lint](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml)
[![Maintenance validation](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/validate-maintenance.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/validate-maintenance.yml)
[![Package freshness](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/freshness.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/freshness.yml)

A security-conscious, reproducible guide for preparing a new Mac without turning one person's preferences into universal defaults.

**Last human review:** July 21, 2026<br>
**Automated validation:** every relevant pull request and every Monday<br>
**Upstream freshness review:** monthly<br>
**Editorial review:** quarterly, after major macOS releases, and annually on a clean or disposable Mac<br>
**Target:** macOS Sonoma 14 or newer, with macOS Tahoe 26 as the current primary release<br>
**Hardware:** Apple silicon first; native Intel execution is tested while Homebrew supports it

## What this repository optimizes for

The setup follows six rules:

1. Protect data and establish recovery paths before installing developer tools.
2. Keep the default package set small and assign one owner to each responsibility.
3. Use Apple's Command Line Tools for the bootstrap Git and compiler.
4. Use only the Homebrew prefix supported by the current native architecture.
5. Automate deterministic package installation, not sign-in, privacy grants, credentials, or taste.
6. Make every state-changing script inspectable, rerunnable, and bounded by explicit options.

It is deliberately **not** a giant “run this and replace your whole Mac” script.

## Supported ownership model

| Responsibility | Owner | Default? |
| --- | --- | --- |
| Bootstrap Git and clang | Apple Command Line Tools | Required before cloning |
| Package installation | Native Homebrew | Installed explicitly |
| GitHub operations | [GitHub CLI](https://cli.github.com/manual/) | Foundation |
| Non-Python project tools | [mise](https://mise.jdx.dev/) | Foundation |
| Python projects and tools | [uv](https://docs.astral.sh/uv/) | Foundation |
| Newer standalone Git | [Homebrew Git](https://git-scm.com/docs/git) | Optional |
| Personal applications and preferences | User-selected layers | Optional |

Apple's Git is not a temporary accident: it is the documented bootstrap and default Git. `Brewfile.git` exists only for a project or feature that requires a newer independently managed Git.

## Start here

### 1. Establish the manual security and recovery baseline

Complete Setup Assistant, install all available macOS security updates, configure FileVault and recovery, enable the firewall where appropriate, and create a tested backup.

Read these before automation:

- [Before you start](docs/00-before-you-start.md)
- [Security and backups](docs/01-security-and-backups.md)
- [Migration](docs/migration.md), when moving from another Mac

### 2. Install and verify Apple's Command Line Tools

```bash
xcode-select --install
```

After the graphical installer finishes, open a new Terminal window and verify that the selected tools actually run:

```bash
xcode-select -p
xcrun --find git
git --version
xcrun --find clang
clang --version
```

These tools provide the Git used in the next step. Homebrew is not required to clone this repository.

### 3. Clone and run the preflight audit

```bash
git clone https://github.com/jessewalberg/modern-mac-setup.git
cd modern-mac-setup
./scripts/audit.sh --preflight
```

Preflight treats missing Homebrew packages as expected. It blocks only conditions that make the bootstrap unsafe or unusable, such as translated execution, broken Apple developer tools, an unsupported macOS version, or a wrong-architecture Homebrew installation.

### 4. Review and bootstrap the foundation

```bash
less scripts/bootstrap.sh
cat Brewfile
cat snippets/zshrc

./scripts/bootstrap.sh \
  --install-homebrew \
  --configure-shell
```

The script:

- refuses root and Rosetta-translated execution;
- requires working Apple Git and clang, not merely an `xcode-select` path;
- selects `/opt/homebrew` on Apple silicon or `/usr/local` on Intel;
- rejects a different Homebrew prefix earlier in `PATH`;
- downloads the official Homebrew installer from an immutable reviewed commit;
- verifies the downloaded Git blob before execution;
- installs only GitHub CLI, `mise`, and `uv` by default;
- adds or updates one versioned shell block after backing up an existing `.zshrc`.

Open a new Terminal window after shell configuration, return to the repository, and verify:

```bash
./scripts/audit.sh --post-bootstrap --deep
```

## Optional layers

Install command-line conveniences only after the foundation works:

```bash
./scripts/bootstrap.sh --with-cli
```

The optional CLI layer contains:

| Tool | Command | Purpose |
| --- | --- | --- |
| [bat](https://github.com/sharkdp/bat#readme) | `bat` | Syntax-aware file viewing |
| [fd](https://github.com/sharkdp/fd#readme) | `fd` | Ergonomic file search |
| [fzf](https://github.com/junegunn/fzf#readme) | `fzf` | Interactive fuzzy filtering |
| [jq](https://jqlang.org/manual/) | `jq` | JSON querying and transformation |
| [ripgrep](https://github.com/BurntSushi/ripgrep#readme) | `rg` | Fast recursive text search |
| [`tree`](https://formulae.brew.sh/formula/tree) | `tree` | Directory hierarchy display |

Install Homebrew Git only for a documented requirement:

```bash
./scripts/bootstrap.sh --with-homebrew-git
command -v git
git --version
```

The audit reports whether active Git comes from Apple, the native Homebrew prefix, or a custom path.

## Applications are deliberate choices

No graphical applications are installed by default. Copy the reviewed example, uncomment only the selected tools, and inspect the result:

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
cat Brewfile.apps
./scripts/bootstrap.sh --apps Brewfile.apps
```

| Category | Reviewed options |
| --- | --- |
| Password manager | [1Password](https://support.1password.com/), [Bitwarden](https://bitwarden.com/help/) |
| Browser | [Firefox](https://support.mozilla.org/products/firefox) |
| Editor | [Visual Studio Code](https://code.visualstudio.com/docs), [Zed](https://zed.dev/docs) |
| Terminal | [Ghostty](https://ghostty.org/docs), [iTerm2](https://iterm2.com/documentation.html) |
| Containers | [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/), [OrbStack](https://docs.orbstack.dev/), [Podman Desktop](https://podman-desktop.io/docs/installation/macos-install) |
| Window management and launcher | [Rectangle](https://github.com/rxhanson/Rectangle#readme), [Raycast](https://manual.raycast.com/) |
| Configuration management | [chezmoi](https://www.chezmoi.io/user-guide/command-overview/), [`mas`](https://github.com/mas-cli/mas#readme) |

A listing is not an endorsement for every machine. Review vendor ownership, licensing, requested permissions, update behavior, architecture support, data handling, and removal before selecting an application.

## Repository development environment

The Mac foundation does not globally install this repository's test stack. Contributors use the pinned tools in [`mise.toml`](mise.toml): Node.js, Ruby, ShellCheck, and `shfmt`.

```bash
mise install
mise run lint
```

This separation keeps production setup requirements distinct from repository-maintenance requirements.

## Optional macOS preferences

Preview four narrow changes without writing anything:

```bash
./scripts/macos-defaults.sh
```

Apply them only after review:

```bash
./scripts/macos-defaults.sh --apply
```

The script records previous values, then shows filename extensions, enables Finder's path and status bars, and places screenshots in `~/Pictures/Screenshots`. It does not disable Gatekeeper, System Integrity Protection, quarantine, the firewall, or automatic security updates.

## Continuous maintenance and evidence

The repository distinguishes three kinds of evidence:

- **static and mocked validation** on Linux;
- **pre-provisioned hosted macOS package tests** on Apple-silicon and Intel runners;
- **clean-machine acceptance tests** performed manually on a clean or disposable Mac after material platform changes and at least annually.

A green workflow proves only that the tested path worked at that commit. It is not a security certification and does not make every optional application appropriate. See [Maintenance policy](MAINTENANCE.md) and [Clean-machine acceptance test](docs/acceptance-test.md).

## Documentation index

| Topic | Document |
| --- | --- |
| Decisions before touching the machine | [Before you start](docs/00-before-you-start.md) |
| FileVault, updates, firewall, permissions, and backup | [Security and backups](docs/01-security-and-backups.md) |
| Homebrew, architecture, trust pins, and flags | [Bootstrap](docs/02-bootstrap.md) |
| Git ownership, identity, authentication, and signing | [Git and GitHub](docs/03-git-and-github.md) |
| Python with `uv`; other runtimes with `mise` | [Runtimes](docs/04-runtimes.md) |
| Choosing apps and applying narrow preferences | [Apps and preferences](docs/05-apps-and-preferences.md) |
| Updates, drift, and recurring checks | [Maintenance](docs/06-maintenance.md) |
| Clean versus migrated setup | [Migration](docs/migration.md) |
| Architecture and design rationale | [Design principles](docs/design-principles.md) |
| Common failures and safe corrections | [Troubleshooting](docs/troubleshooting.md) |
| End-to-end release evidence | [Acceptance test](docs/acceptance-test.md) |
| Primary platform and tool documentation | [References](docs/references.md) |
| Automated and human review commitments | [Maintenance policy](MAINTENANCE.md) |
| Contribution rules | [Contributing](CONTRIBUTING.md) |
| Vulnerability reporting | [Security policy](SECURITY.md) |

## What this repository will not do

It will not:

- disable SIP, Gatekeeper, app quarantine, FileVault, or automatic security updates;
- run Homebrew as root or install it into a nonstandard prefix;
- silently use an Intel Homebrew from a native Apple-silicon process, or vice versa;
- generate, copy, upload, or commit private keys, tokens, recovery codes, or identity data;
- grant Accessibility, Full Disk Access, Screen Recording, or other privacy permissions;
- install competing applications, container platforms, shell frameworks, or language runtimes by default;
- remove software merely because it is absent from a Brewfile;
- promise bit-for-bit reproducibility from Homebrew, which is a rolling package manager.

## License

MIT. See [LICENSE](LICENSE).
