# Modern Mac Setup

[![Lint](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml)
[![Maintenance validation](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/validate-maintenance.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/validate-maintenance.yml)
[![Package freshness](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/freshness.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/freshness.yml)

A security-conscious, reproducible guide for setting up a new Mac without turning one person's preferences into universal defaults.

**Last human review:** July 21, 2026<br>
**Automated validation:** every relevant pull request and every Monday<br>
**Upstream freshness review:** monthly<br>
**Editorial review:** quarterly, after major macOS releases, and annually on a clean Mac<br>
**Target:** macOS Sonoma 14 or newer, with macOS Tahoe 26 as the current primary release<br>
**Hardware:** Apple silicon first; native Intel execution is supported while Homebrew supports it

## Continuously maintained

This is not intended to become a setup guide that slowly goes stale. The repository continuously checks that its Homebrew formulae and casks still resolve, that the foundation and CLI bundles install on a clean macOS runner, that documented command names exist, and that package metadata remains consistent with the Brewfiles and README.

Every month, automation creates or refreshes a public package-freshness issue. Every quarter, it opens a human editorial-review checklist covering macOS changes, permissions, licensing, ownership, alternatives, and outdated advice that could still pass technically. GitHub Actions dependencies are reviewed weekly through Dependabot, and the complete guide is exercised on a clean or disposable Mac at least annually and after material platform changes.

A green badge means the tested path worked at that commit. It is not a security certification and does not mean every optional application is right for every user. See [Continuous maintenance policy](MAINTENANCE.md) for the exact guarantees, cadence, and public evidence.

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

The bootstrap installs [Homebrew](https://docs.brew.sh/) when requested, then uses it to install the small foundation below.

### Foundation tools

| Tool | Command | What it does | Example |
| --- | --- | --- | --- |
| [Git](https://git-scm.com/docs/git) | `git` | Tracks source history and exchanges commits with remote repositories. | `git status` |
| [GitHub CLI](https://cli.github.com/manual/) | `gh` | Authenticates to GitHub and works with repositories, issues, pull requests, and releases from the terminal. | `gh auth login` |
| [mise](https://mise.jdx.dev/) | `mise` | Installs and selects project-pinned versions of Node, Go, Java, Ruby, Terraform, and other tools. | `mise use node@22` |
| [uv](https://docs.astral.sh/uv/) | `uv` | Manages Python versions, virtual environments, project dependencies, lockfiles, and Python command-line tools. | `uv sync` |

These are managers and developer foundations, not a global installation of every language runtime. Runtime versions should normally be declared by each project.

### Optional command-line utilities

Passing `--with-cli` installs the tools in [`Brewfile.cli`](Brewfile.cli). They are conveniences rather than requirements; remove any that do not earn a place in your workflow.

| Tool | Command | What it does | Example |
| --- | --- | --- | --- |
| [bat](https://github.com/sharkdp/bat#readme) | `bat` | Displays text files with syntax highlighting, line numbers, paging, and Git change markers. | `bat README.md` |
| [fd](https://github.com/sharkdp/fd#readme) | `fd` | Finds files with simpler defaults than `find`, including automatic `.gitignore` handling. | `fd -e md` |
| [fzf](https://github.com/junegunn/fzf#readme) | `fzf` | Interactively filters a list using fuzzy matching; useful for files, branches, history, and custom shell workflows. | `fd --type f \| fzf` |
| [jq](https://jqlang.org/manual/) | `jq` | Reads, filters, transforms, and formats JSON on the command line. | `jq '.name' package.json` |
| [ripgrep](https://github.com/BurntSushi/ripgrep#readme) | `rg` | Recursively searches text quickly while respecting `.gitignore` and skipping binary files by default. | `rg 'TODO' .` |
| [ShellCheck](https://www.shellcheck.net/) | `shellcheck` | Statically analyzes shell scripts for common bugs, quoting errors, and portability problems. | `shellcheck scripts/*.sh` |
| [shfmt](https://github.com/mvdan/sh#shfmt) | `shfmt` | Formats shell scripts consistently; this repository also uses it in CI. | `shfmt -d scripts/*.sh` |
| [`tree`](https://formulae.brew.sh/formula/tree) | `tree` | Prints a directory hierarchy in a compact tree-shaped view. | `tree -L 2` |

Homebrew package and executable names are not always the same. The notable example here is `ripgrep`: Homebrew installs the package named `ripgrep`, but the terminal command is `rg`.

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

The example groups alternatives so competing tools are not silently installed together.

| Category | Options | What they are for |
| --- | --- | --- |
| Password manager | [1Password](https://support.1password.com/), [Bitwarden](https://bitwarden.com/help/) | Store credentials, passkeys, secure notes, and recovery material outside this repository. Choose one. |
| Browser | [Firefox](https://support.mozilla.org/products/firefox) | Adds a second browser for compatibility testing, profile separation, or personal preference. Safari is already installed. |
| Editor | [Visual Studio Code](https://code.visualstudio.com/docs), [Zed](https://zed.dev/docs) | Edit code and integrate language tooling. Choose the editor that fits the projects and team. |
| Terminal | [Ghostty](https://ghostty.org/docs), [iTerm2](https://iterm2.com/documentation.html) | Replace Terminal.app when their rendering, profiles, panes, or automation are genuinely useful. |
| Containers | [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/), [OrbStack](https://docs.orbstack.dev/), [Podman Desktop](https://podman-desktop.io/docs/installation/macos-install) | Run Linux containers and related development environments. Check licensing, architecture support, and team compatibility before choosing one. |
| Window management and launcher | [Rectangle](https://github.com/rxhanson/Rectangle#readme), [Raycast](https://manual.raycast.com/) | Add keyboard-driven window layouts or launcher automation; both may request meaningful macOS permissions. |
| Configuration management | [chezmoi](https://www.chezmoi.io/user-guide/command-overview/), [`mas`](https://github.com/mas-cli/mas#readme) | Manage dotfiles across machines or install Mac App Store applications from the command line. Neither is enabled by default. |

See [Applications and preferences](docs/05-apps-and-preferences.md) for the selection criteria and permission review process.

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

## Documentation index

Every repository guide is linked here so the README remains the entry point.

| Topic | Document |
| --- | --- |
| Continuous automated and human maintenance | [Maintenance policy](MAINTENANCE.md) |
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
| Official platform and tool documentation | [References](docs/references.md) |
| Contribution and acceptance rules | [Contributing](CONTRIBUTING.md) |
| Reporting security-sensitive problems | [Security policy](SECURITY.md) |
| Reuse terms | [MIT license](LICENSE) |

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
2. Update `config/packages.yml` and the relevant documentation.
3. Run `ruby scripts/validate-catalog.rb`.
4. Review the diff.
5. Run `brew bundle check --no-upgrade`.
6. Apply with `brew bundle install --no-upgrade`.
7. Commit the rationale, not only the package name.

Project runtime versions belong in each project's `mise.toml`, `.tool-versions`, `.python-version`, or equivalent lock/configuration files. The new-Mac repository should not become a hidden source of project requirements.

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md) for the acceptance rules. Security-sensitive reports should follow [SECURITY.md](SECURITY.md). Never paste credentials, private keys, recovery keys, serial numbers, or unredacted diagnostic archives into an issue.

## License

MIT. See [LICENSE](LICENSE).
