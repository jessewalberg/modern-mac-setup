# Modern Mac Setup

[![Lint](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml/badge.svg)](https://github.com/jessewalberg/modern-mac-setup/actions/workflows/lint.yml)

A security-conscious, reproducible guide for setting up a new Mac without turning one person's preferences into universal defaults.

**Last reviewed:** July 21, 2026<br>
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
8. Review Finder, pointer, keyboard, Dock, and window ergonomics.
9. Add applications only after reviewing their permissions, update model, and license.

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

## Explore more tools without installing everything

The baseline and `Brewfile.cli` are deliberately small. The [researched tool and application catalog](docs/tool-catalog.md) covers many current alternatives, including:

- Chrome, Firefox, Brave, Edge, Vivaldi, Orion, Arc, and DuckDuckGo;
- Ghostty, iTerm2, cmux, Warp, WezTerm, kitty, and Tabby;
- VS Code, Cursor, Zed, Windsurf, Sublime Text, Nova, BBEdit, JetBrains, Neovim, and Helix;
- Claude Code, Codex, OpenCode, Aider, and multi-agent workspaces;
- Docker Desktop, OrbStack, Podman, Rancher Desktop, Colima, UTM, Parallels, and VMware Fusion;
- API clients, database clients, Git GUIs, window managers, launchers, input tools, display tools, password managers, and system utilities.

Each entry explains the recurring use case, Homebrew declaration, alternatives, and important permission, data, licensing, or overlap considerations. Inclusion means “worth evaluating,” not “install by default.”

For optional formulae, AI agents, cloud tools, and role-specific developer utilities:

```bash
cp Brewfile.extras.example Brewfile.local
${EDITOR:-nano} Brewfile.local
brew bundle check --file=Brewfile.local --no-upgrade
brew bundle install --file=Brewfile.local --no-upgrade
```

`Brewfile.local` is ignored by Git. Uncomment only tools that solve an actual recurring problem.

## Add applications deliberately

No graphical applications are installed by default. [`Brewfile.apps.example`](Brewfile.apps.example) now contains a broad commented menu rather than a tiny implied shortlist.

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
cat Brewfile.apps
brew bundle check --file=Brewfile.apps --no-upgrade
brew bundle install --file=Brewfile.apps --no-upgrade
```

The example groups competing tools so they are not silently installed together. Start with the built-in macOS option, then choose one or none per responsibility. See the [tool catalog](docs/tool-catalog.md) and [Applications and preferences](docs/05-apps-and-preferences.md).

## Customize Finder and ergonomics

Package installation is only part of a usable Mac. The [macOS ergonomics and Finder guide](docs/macos-ergonomics.md) walks through supported settings for:

- making List view the normal Finder view and applying it as a default;
- Finder columns, sorting, sidebar, search scope, filename extensions, path bar, and status bar;
- faster mouse or trackpad tracking and the current pointer-acceleration toggle;
- scrolling speed, secondary click, Tap to Click, and Three Finger Drag;
- key repeat, delay, keyboard navigation, and shortcut conflicts;
- Dock behavior, current built-in window tiling, Mission Control, and Hot Corners;
- screenshot location, display comfort, notifications, Focus, and login items;
- deciding when tools such as LinearMouse, Mos, Rectangle, BetterTouchTool, BetterDisplay, or Lunar are justified.

Finder List view and pointer speed remain manual because the correct behavior depends on the user, mouse, trackpad, display, and accessibility needs. The guide uses supported Finder and System Settings controls instead of undocumented preference commands copied from old articles.

## Optional narrow macOS preferences

The preference script changes only four narrow, documented settings:

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

The script records the previous values before applying changes. It never disables Gatekeeper, System Integrity Protection, quarantine, the firewall, automatic updates, or other security controls. It intentionally does not set Finder List view, mouse speed, acceleration, key repeat, Dock behavior, trackpad gestures, or display scaling.

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
| Decisions before touching the machine | [Before you start](docs/00-before-you-start.md) |
| FileVault, updates, firewall, permissions, and backup | [Security and backups](docs/01-security-and-backups.md) |
| Homebrew, bundles, bootstrap flags, and shell setup | [Bootstrap](docs/02-bootstrap.md) |
| Identity, authentication, SSH, and commit signing | [Git and GitHub](docs/03-git-and-github.md) |
| Python with `uv`; other runtimes with `mise` | [Runtimes](docs/04-runtimes.md) |
| Choosing apps and applying narrow preferences | [Apps and preferences](docs/05-apps-and-preferences.md) |
| Finder, mouse, trackpad, keyboard, Dock, and windows | [macOS ergonomics](docs/macos-ergonomics.md) |
| Broad researched choices with tradeoffs | [Tool and application catalog](docs/tool-catalog.md) |
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
- install every plausible browser, terminal, editor, AI agent, container engine, or utility;
- force personal pointer, keyboard, window, Dock, display, or accessibility preferences;
- remove software merely because it is absent from a Brewfile;
- promise bit-for-bit reproducibility from Homebrew, which is a rolling package manager rather than a lockfile system.

## Updating the setup

Change one layer at a time:

1. Add or remove package declarations in a Brewfile.
2. Read the linked vendor and Homebrew documentation.
3. Review the diff and competing owners for the same responsibility.
4. Run `brew bundle check --no-upgrade` against the selected file.
5. Apply with `brew bundle install --no-upgrade`.
6. Commit the rationale, not only the package name.

Project runtime versions belong in each project's `mise.toml`, `.tool-versions`, `.python-version`, or equivalent lock/configuration files. The new-Mac repository should not become a hidden source of project requirements.

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md) for the acceptance rules. Security-sensitive reports should follow [SECURITY.md](SECURITY.md). Never paste credentials, private keys, recovery keys, serial numbers, or unredacted diagnostic archives into an issue.

## License

MIT. See [LICENSE](LICENSE).
