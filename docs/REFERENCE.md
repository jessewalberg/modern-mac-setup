# Reference

Use this document when the README is not enough. It keeps the reasoning, recovery notes, and less-common commands in one place instead of spreading them across a documentation tree.

**Last reviewed:** July 22, 2026

## Principles

- Protect data and recovery paths before installing tools.
- Automate reviewable package state, not personal taste or privacy grants.
- Keep the default install small; optional applications stay optional.
- Give each responsibility one owner: macOS, Homebrew, `uv`, `mise`, or the project.
- Run Apple-silicon tools natively and avoid a second Intel Homebrew.
- Never store credentials, private keys, recovery material, or personal identity in this public repository.
- Prefer current primary sources over copied setup recipes.

A Brewfile is a reviewable package list, not a cryptographic lockfile. Stronger reproducibility belongs inside projects through lockfiles, containers, or another project-scoped environment.

## Security, recovery, and migration

Before installing developer tools:

1. Install current macOS updates and Background Security Improvements.
2. Enable FileVault and store the recovery method somewhere other than the Mac.
3. Enable the application firewall and disable sharing services that are not deliberately used.
4. Set a prompt screen lock and review login items and privacy permissions.
5. Configure an encrypted backup and restore a representative file.

Review **System Settings → Privacy & Security** for Accessibility, Full Disk Access, Screen Recording, Input Monitoring, Files & Folders, Automation, Developer Tools, Local Network, Camera, and Microphone. Grant access only for an understood feature.

For a migration, prefer moving data and selected application state while reinstalling software from current sources. Do not copy Homebrew prefixes, Cellar paths, caches, `.venv`, `node_modules`, old container disks, or an unreviewed `.ssh` directory.

An old Homebrew inventory can be useful as evidence:

```bash
brew bundle dump --file="$HOME/Desktop/old-mac.Brewfile" --force
```

Review every line before moving a declaration into this repository. Reauthenticate GitHub, cloud tools, VPNs, and package registries on the new Mac rather than copying opaque credential stores.

## Bootstrap and package management

The bootstrap relies on macOS, Apple Command Line Tools, GitHub, Homebrew, and each selected upstream application. Formulae and casks have different trust models: casks commonly install vendor applications and may run vendor installers.

The script downloads Homebrew's official installer from an immutable reviewed commit before executing it. The pin prevents silent changes, but it does not eliminate the need to trust and periodically review Homebrew's official release process.

Supported Homebrew prefixes are:

- `/opt/homebrew` on Apple silicon;
- `/usr/local` on Intel macOS.

The bootstrap refuses to run as root or from a Rosetta-translated terminal. It never uses versioned Cellar paths.

### Package layers

| Layer | File | Purpose |
| --- | --- | --- |
| Foundation | `Brewfile` | Git, GitHub CLI, `mise`, and `uv` |
| Optional CLI | `Brewfile.cli` | Small terminal and validation utilities |
| Optional apps | Local `Brewfile.apps` | Explicitly selected applications |

The bootstrap runs `brew update`, then installs bundles with `--no-upgrade` to avoid upgrading unrelated software as a side effect. That is not version pinning.

Useful options:

```text
--install-homebrew   allow Homebrew installation when brew is absent
--with-cli           install Brewfile.cli
--apps FILE          install a reviewed application Brewfile
--configure-shell    add the managed Homebrew and mise block to ~/.zshrc
--no-update          skip brew update
--dry-run            print commands without changing the Mac
```

The shell configuration adds one marked block and creates a timestamped backup. It does not install a framework, prompt, theme, aliases, or plugins.

## Git and GitHub

Set authorship explicitly:

```bash
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR COMMIT EMAIL"
git config --global init.defaultBranch main
git config --global fetch.prune true
```

Authenticate through GitHub CLI:

```bash
gh auth login
gh auth status --hostname github.com
```

Choose HTTPS or SSH deliberately. Never place a token in a remote URL or commit a private key. For work and personal identities, use conditional Git includes rather than repeatedly changing one global email.

Commit signing is optional and separate from transport authentication. Use it only with a workable key-rotation and recovery plan.

## Project runtimes

Use `uv` for Python and `mise` for other runtimes. Keep versions in each project.

Python example:

```bash
uv init
uv python pin 3.14
uv add requests
uv run python -c 'import requests; print(requests.__version__)'
```

Use a version supported by the project; `3.14` is only an example. Commit `pyproject.toml`, `uv.lock`, and the relevant version file, but not `.venv`.

For occasional Python tools:

```bash
uvx ruff check .
```

For a persistent isolated tool:

```bash
uv tool install ruff
```

Other runtimes:

```bash
mise use node@X.Y.Z
mise use go@X.Y.Z
mise install
mise current
```

Commit the generated project configuration. Avoid global registry packages when the project can declare the dependency or run it ephemerally.

## Applications, agents, and communities

Before adding an application, ask what recurring task it solves, who publishes it, how it updates, which permissions it requests, what data leaves the Mac, whether its license fits, and how it will be removed.

Start with built-in macOS applications when they are sufficient. Choose one option per overlapping category. `Brewfile.apps.example` includes commented choices for password managers, browsers, Discord or Slack, editors, coding agents, terminal workspaces such as cmux, containers, launchers, and window managers.

A browser is enough for occasional community access. Desktop Discord and Slack clients add notifications, background activity, local caches, account sessions, and another update channel.

### AI coding tools

Coding agents may read repositories, edit files, run commands, access networks, and load project instructions. Start with one and review:

- account, subscription, API billing, telemetry, and data use;
- workspace trust, file writes, shell approval, sandboxing, and unattended modes;
- plugins, hooks, skills, extensions, and MCP servers;
- whether Homebrew or the vendor owns installation and updates.

Before the first session, check `git status`, use a recoverable branch or worktree, begin with limited permissions, review every command, inspect the diff, and run tests yourself.

Aider is intentionally outside the Brewfile because its maintainers recommend an isolated Python environment:

```bash
uv tool install --force --python python3.12 --with pip aider-chat@latest
```

### Terminals and communities

Terminal.app is sufficient for bootstrap. Choose cmux for a broader workspace around terminals and coding agents, Ghostty for a focused terminal, or iTerm2 for its mature profile and automation features. Do not install overlapping tools without a concrete reason.

Use official documentation for supported behavior, Discussions or forums for searchable questions, chat for conversation, and issue trackers for reproducible defects. Useful stable entry points include:

- [cmux community](https://cmux.com/community)
- [Mac Admins](https://www.macadmins.org/)
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Homebrew Discussions](https://github.com/orgs/Homebrew/discussions)
- [Astral community](https://discord.com/invite/astral-sh)
- [Docker Community](https://www.docker.com/community/)

Treat community commands as suggestions, not authority. Remove secrets, private repository names, internal hosts, serial numbers, and customer data before posting logs or screenshots.

## Optional macOS preferences

The preferences script changes only four visible choices:

- show all filename extensions;
- show Finder's path bar;
- show Finder's status bar;
- save future screenshots in `~/Pictures/Screenshots`.

Preview first:

```bash
./scripts/macos-defaults.sh
```

Apply after review:

```bash
./scripts/macos-defaults.sh --apply
```

Previous raw values are recorded under `~/.local/state/modern-mac-setup/defaults/TIMESTAMP/`. The script briefly restarts Finder and SystemUIServer. The recorded values are diagnostic; there is not yet a one-command restore.

Manual paths are available in Finder settings and **Shift-Command-5 → Options**. Keep accessibility, keyboard, trackpad, Dock, display, notification, Focus, and login-item choices manual because they depend on the person and hardware.

## Maintenance

A maintained setup is a process, not a one-time script.

Regularly:

```bash
brew update
brew outdated
mise outdated
./scripts/audit.sh --deep
```

Apply reviewed upgrades with `brew upgrade`. Use `brew cleanup` deliberately, and do not run `brew bundle cleanup --force` casually because it may remove intentionally installed software.

Also review macOS updates, browser and password-manager updates, login items, privacy permissions, GitHub keys and tokens, backup status, and a representative restore.

Repository automation checks shell and Markdown quality, package-catalog consistency, current Homebrew resolution, foundation installation, upstream freshness, and automation dependencies. A green workflow proves only the tested path at that commit; it is not a security certification.

## Troubleshooting

| Symptom | First action |
| --- | --- |
| Command Line Tools missing | Run `xcode-select --install`, finish the installer, then verify `xcode-select -p` |
| `brew` exists but is not found | Load `eval "$(/opt/homebrew/bin/brew shellenv)"` on Apple silicon or the `/usr/local` equivalent on Intel |
| Bootstrap reports Rosetta | Relaunch the terminal natively; do not install a second Intel Homebrew |
| Homebrew permissions error | Run `brew --prefix` and `brew doctor`; do not use `sudo brew`, `chmod -R 777`, or broad ownership changes |
| GitHub authentication fails | Run `gh auth status --hostname github.com`, then `gh auth login` |
| `mise` tools unavailable | Open a new terminal, then run `mise doctor` and inspect the single managed shell block |
| `uv` tool unavailable | Run `uv tool dir --bin` and `uv tool list`; prefer `uv run` or `uvx` for project commands |

When a cask fails, inspect `brew info --cask CASK_NAME`, confirm the token in Homebrew's catalog, and check the vendor's documentation. Do not bypass Gatekeeper or quarantine for an unverified download.

## Primary sources

- [Apple security releases](https://support.apple.com/en-us/100100)
- [Apple FileVault](https://support.apple.com/guide/mac-help/protect-data-on-your-mac-with-filevault-mh11785/mac)
- [Apple Time Machine](https://support.apple.com/en-us/104984)
- [Homebrew installation](https://docs.brew.sh/Installation)
- [Homebrew supply-chain security](https://docs.brew.sh/Supply-Chain-Security)
- [Homebrew Bundle](https://docs.brew.sh/Manpage#bundle-subcommand)
- [GitHub CLI manual](https://cli.github.com/manual/)
- [GitHub SSH documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [mise documentation](https://mise.jdx.dev/)
- [uv documentation](https://docs.astral.sh/uv/)
