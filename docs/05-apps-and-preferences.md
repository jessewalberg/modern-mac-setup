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

## AI editors and coding agents

Coding agents deserve a stricter review than ordinary applications because they may read repositories, modify files, execute shell commands, use network services, and load project instructions or third-party tools.

The application example includes current editor and terminal-agent choices, but every line remains commented. Start with one agent rather than installing a stack of overlapping tools. Review the [optional AI coding-tools guide](07-ai-coding-tools.md) before selecting an editor, agent, installation owner, account, permission mode, or MCP integration.

This repository never signs in to a provider, stores API keys, enables unattended execution, or configures plugins, hooks, skills, extensions, or MCP servers.

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

## Review macOS preferences in plain language

Most copied `defaults write` collections use undocumented implementation keys, mix personal taste with security changes, and provide no reliable rollback. This repository keeps preferences separate from the developer bootstrap and changes only four visible choices.

No additional preference-management CLI is required today. Four settings do not justify another dependency or update channel. Reconsider that only if a future tool can explain, inspect, selectively apply, verify, and restore each setting better than this small script and the native macOS interface.

### Finder visibility

#### Show all filename extensions — recommended for development

**What it does:** Finder displays extensions such as `.md`, `.json`, `.sh`, and `.png`.

**Why consider it:** File types become explicit instead of being inferred from icons or the application associated with a file.

**Manual equivalent:** **Finder → Settings → Advanced → Show all filename extensions**.

**Implementation:** `defaults write NSGlobalDomain AppleShowAllExtensions -bool true`

Apple notes that changing a filename extension can stop the original application from opening the file. Showing extensions does not change them; it only makes them visible.

#### Show the Finder path bar — recommended

**What it does:** Finder displays the current folder hierarchy at the bottom of each window.

**Why consider it:** The location of a file is visible, and parent folders are easier to open.

**Manual equivalent:** **Finder → View → Show Path Bar**.

**Implementation:** `defaults write com.apple.finder ShowPathbar -bool true`

#### Show the Finder status bar — optional

**What it does:** Finder displays the number of items and available disk space.

**Why consider it:** Folder and disk context stays visible while browsing files.

**Manual equivalent:** **Finder → View → Show Status Bar**.

**Implementation:** `defaults write com.apple.finder ShowStatusBar -bool true`

### Screenshot storage

#### Save future Screenshot files in `~/Pictures/Screenshots` — personal choice

**What it does:** Creates `~/Pictures/Screenshots` when needed and changes the save destination used by the built-in Screenshot tools.

**Why consider it:** Captures no longer accumulate on the Desktop.

**Tradeoff:** People who deliberately use the Desktop as a temporary capture queue may prefer the macOS default.

**Manual equivalent:** Press **Shift-Command-5**, choose **Options → Save to → Other Location**, then select a folder.

The equivalent commands are:

```bash
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
```

Existing screenshots and screen recordings are not moved.

### What the script actually does

Run the script without arguments to see the same human explanation followed by the exact commands:

```bash
./scripts/macos-defaults.sh
```

Nothing is changed in preview mode. Applying performs these actions in order:

1. records the previous raw value or absence of each of the four keys;
2. creates `~/Pictures/Screenshots` when it does not exist;
3. writes the three Finder choices;
4. writes the Screenshot save location;
5. restarts Finder;
6. restarts SystemUIServer.

The last two commands do not delete files. They terminate those user-interface processes so macOS relaunches them with the new values. Finder windows or parts of the menu bar may briefly disappear.

Apply all four only after reviewing them:

```bash
./scripts/macos-defaults.sh --apply
```

Previous raw values are stored under:

```text
~/.local/state/modern-mac-setup/defaults/TIMESTAMP/
```

Those files are a diagnostic record, not an automatic restore bundle. Until a reviewed restore command exists, use the manual paths above to change a setting back. Avoid importing a complete old preference domain because that can overwrite unrelated settings changed later.

### Other quality-of-life choices to review manually

These are common things to consider, not universal recommendations:

- **Finder sidebar and new-window location:** keep frequently used folders visible and decide whether new Finder windows open to Recents, the home folder, or another location.
- **Finder search scope and folder ordering:** decide whether searches start in the current folder and whether folders appear first when sorting by name.
- **Screenshot workflow:** hold **Control** with a screenshot shortcut to copy the capture to the Clipboard instead of creating a file.
- **Keyboard and trackpad:** review key repeat, modifier keys, tap-to-click, scrolling direction, gestures, and accessibility needs on the actual hardware.
- **Dock and window management:** choose Dock position, size, auto-hide, recent-app behavior, tiling, and Mission Control based on screen size and workflow.
- **Login items and background activity:** review **System Settings → General → Login Items & Extensions** after installing applications.
- **Default applications:** choose the default browser and review file associations rather than allowing each installer to decide.
- **Notifications and Focus:** allow interruptions intentionally, especially from newly installed communication and developer tools.
- **Displays:** review scaling, color profile, HDR, Night Shift, and arrangement on each display.
- **Cloud synchronization:** decide which Desktop, Documents, Photos, password, and application data should sync before assuming it is a backup.

Keep these manual because they depend on hardware, accessibility, account ownership, privacy, or personal workflow. Accessibility, Full Disk Access, Screen Recording, Input Monitoring, and other privacy grants must always remain user decisions.

Continue with [Optional AI Coding Tools](07-ai-coding-tools.md) or [Maintenance](06-maintenance.md).
