# Applications and Preferences

Application choice is where setup guides become stale and overly personal. This repository therefore separates three things:

1. a very small baseline that can be automated safely;
2. broad researched catalogs of credible options;
3. personal choices that remain local to each Mac.

An entry in the catalog means “worth evaluating for this use case,” not “best,” “required,” or “safe for every organization.”

## Review each application

Before adding a cask, answer:

1. What recurring task does the application solve?
2. Is a built-in macOS tool already sufficient?
3. Does another selected tool already own the same responsibility?
4. Who publishes and signs it?
5. How does it update, and does Homebrew remain the correct update owner?
6. What Accessibility, Full Disk Access, Screen Recording, Input Monitoring, network, kernel/system extension, or login-item permissions does it request?
7. What source code, documents, clipboard data, credentials, prompts, telemetry, or other data leaves the Mac?
8. Does the license permit personal and commercial use?
9. Is it native to Apple silicon, universal, or dependent on Rosetta?
10. How will its configuration and data be backed up or reproduced?
11. What is the removal path?
12. Is its Homebrew package active, non-deprecated, and supplied through an official source?

An application that cannot pass this review should not enter an automated install list.

## Start with the researched catalog

The [tool and application catalog](tool-catalog.md) covers current options across:

- browsers;
- terminals and multi-agent workspaces;
- editors and IDEs;
- AI coding agents;
- containers and virtual machines;
- API and database clients;
- Git graphical clients;
- window managers, launchers, and automation;
- mouse, keyboard, and display enhancements;
- password, network, security, system, note, communication, and transfer tools;
- role-based starting points.

The catalog includes why to choose an option, why not to install it by default, its Homebrew declaration when appropriate, and material trust or overlap concerns.

## Build an application Brewfile

Start from the broad commented example:

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
```

Uncomment one choice per category where alternatives conflict. Then inspect and apply:

```bash
cat Brewfile.apps
brew bundle check --file=Brewfile.apps --no-upgrade
brew bundle install --file=Brewfile.apps --no-upgrade
```

`Brewfile.apps` is ignored by Git. Do not uncomment whole categories merely because the package names are available.

For optional formulae, terminal tools, cloud CLIs, AI agents, and other role-specific developer tools:

```bash
cp Brewfile.extras.example Brewfile.local
${EDITOR:-nano} Brewfile.local
brew bundle check --file=Brewfile.local --no-upgrade
brew bundle install --file=Brewfile.local --no-upgrade
```

`Brewfile.local` is also ignored. A separate private Brewfile can hold work-specific VPN, security, communication, device-management, or licensed applications. Keep credentials and activation material outside every Brewfile.

## Official sources and third-party taps

Default and example install paths use official Homebrew sources. A third-party tap contains executable Ruby package definitions and adds another supply-chain owner.

Some credible applications, including AeroSpace at the current review date, are distributed through a non-official tap rather than the official Homebrew cask repository. The catalog can document such an option, but the copyable example does not silently add or trust its tap. Read Homebrew's [Tap Trust](https://docs.brew.sh/Tap-Trust) documentation and the upstream installation and signing notes before proceeding.

Disabled or deprecated packages remain out of copyable examples even when the upstream product still exists. Recheck both the vendor and Homebrew status rather than preserving an old command.

## App Store applications

The `mas` command can automate Mac App Store installations after the user signs in. It is commented out because App Store identifiers, regional availability, account ownership, and licensing can make public automation brittle.

Record App Store applications only after confirming the numeric identifier with the signed-in account. Never automate Apple-account passwords or multi-factor authentication.

Some products, including the official WireGuard graphical client at the current review date, may be distributed through the App Store rather than an active official Homebrew cask. Document that difference instead of inventing a plausible cask token.

## Browsers

Safari is already present. Add another browser for a concrete reason:

- Chromium compatibility or Chrome extensions;
- Firefox engine testing;
- Google or Microsoft account integration;
- work/personal profile separation;
- a privacy or customization model that has been deliberately chosen.

A web developer may reasonably keep Safari, Chrome, and Firefox for engine coverage. A developer who does not test web applications may need only one browser. The public guide should show Chrome and other credible choices without installing any of them automatically.

## Terminal and shell

Terminal.app and the default zsh are sufficient for bootstrapping. Add another terminal or shell framework only for a concrete requirement.

The catalog includes Ghostty, iTerm2, cmux, Warp, WezTerm, kitty, and Tabby. These are alternatives, not a checklist. cmux is especially relevant to multi-agent workflows; that specialization is exactly why it belongs in the catalog but not in the universal baseline.

Heavy shell frameworks can obscure startup cost, aliases, completion behavior, and security-sensitive hooks. Start with the small managed snippet in `snippets/zshrc`, then add one understood change at a time.

## AI tools

AI editors and agents can read repositories, execute commands, modify files, call networks, store prompts, and consume paid services. Before enabling one, review:

- repository and filesystem scope;
- command approval and sandbox behavior;
- model provider and data-retention terms;
- organization policy;
- credential storage;
- billing and usage limits;
- Git review and rollback workflow.

Start with one agent. Add cmux, tmux, Conductor, Claude Squad, or another orchestration layer only after parallel work creates a real coordination problem.

## Dotfiles

Once the shell, Git, editor, and application configuration grows, use a dotfile manager such as chezmoi or a carefully designed bare Git repository. A dotfile workflow should support:

- templates for work and personal machines;
- encrypted or external secret retrieval rather than committed plaintext;
- backups before replacement;
- explicit handling of machine-local files;
- reviewable diffs;
- a bootstrap path that does not require the secrets it is trying to restore.

Do not symlink an unknown person's entire home-directory configuration into a new Mac.

## Finder, input, and desktop ergonomics

Read [macOS ergonomics and Finder setup](macos-ergonomics.md) for supported controls covering:

- List view and Finder defaults;
- columns, sorting, sidebar, search scope, extensions, path bar, and status bar;
- mouse and trackpad speed, pointer acceleration, scrolling, clicks, and gestures;
- key repeat, navigation, and shortcut conflicts;
- Dock, built-in window tiling, Mission Control, Hot Corners, and screenshots;
- display comfort, text input, notifications, Focus, and login items.

These preferences remain mostly manual because the correct values depend on the user, hardware, accessibility needs, and established muscle memory. The guide uses supported Finder and System Settings controls rather than presenting undocumented preference keys as a permanent API.

## Narrow automated macOS defaults

Most `defaults write` recipes are undocumented implementation details and can change between macOS versions. Many are personal taste presented as optimization.

This repository automates only four settings with clear value and low coupling:

```bash
./scripts/macos-defaults.sh          # preview
./scripts/macos-defaults.sh --apply  # record prior values, then apply
```

The script:

- shows all filename extensions;
- shows Finder's path bar;
- shows Finder's status bar;
- saves screenshots in `~/Pictures/Screenshots`.

The script does not restore full preference domains automatically because importing an old domain snapshot could overwrite unrelated later settings. It records each prior key under:

```text
~/.local/state/modern-mac-setup/defaults/TIMESTAMP/
```

Use those records to restore the old value with a matching typed `defaults write`, or delete a key that was previously absent. Log out or restart affected applications when a value does not refresh immediately.

## Preferences that remain manual

Keep these manual because they depend on hardware, accessibility, or personal workflow:

- Finder's default List view and per-folder overrides;
- mouse and trackpad tracking speed and pointer acceleration;
- scrolling and double-click speed;
- trackpad gestures and dragging;
- keyboard repeat and remapping;
- display scaling, color, HDR, and Night Shift;
- notification permissions and Focus modes;
- Dock layout and auto-hide;
- window tiling, Hot Corners, and Mission Control;
- sound input and output;
- dictation and Siri;
- iCloud synchronization categories;
- browser extensions;
- Accessibility and Full Disk Access grants.

Continue with [Maintenance](06-maintenance.md).
