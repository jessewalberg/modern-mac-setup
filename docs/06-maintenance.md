# Maintenance

A reproducible setup is a maintained decision record, not a one-time installation script.

## Routine checks

Run monthly or before a material toolchain change:

```bash
softwareupdate --list
brew update
brew outdated
mise outdated
uv tool list
./scripts/audit.sh --post-bootstrap --deep
```

Review output before applying upgrades. Do not combine operating-system upgrades, package-manager upgrades, runtime migrations, and application replacements into one unreviewable change window.

## Homebrew maintenance

Inspect pending changes:

```bash
brew outdated
brew livecheck --installed
brew services list
brew doctor
```

Apply deliberate upgrades:

```bash
brew upgrade FORMULA
brew upgrade --cask CASK
```

Use broad `brew upgrade` only when the scope and rollback implications are understood. Never use `sudo brew`, and do not apply recursive ownership fixes copied from unrelated machines.

Review cleanup before deleting old versions or downloads:

```bash
brew cleanup --dry-run
```

## Brewfile drift

Check each layer independently:

```bash
brew bundle check --file=Brewfile --no-upgrade
brew bundle check --file=Brewfile.git --no-upgrade
brew bundle check --file=Brewfile.cli --no-upgrade
```

An optional layer can be intentionally unsatisfied. Do not use `brew bundle cleanup --force` as a generic synchronization step: absence from a public Brewfile is not permission to remove locally required software.

## Runtime maintenance

Project owners should update versions and lockfiles in their repositories. The new-Mac repository should not silently redefine project requirements.

For this repository's own validation tools:

```bash
mise install
mise outdated
mise run lint
```

Update `mise.toml` in a reviewed pull request and confirm the full suite on Linux plus both hosted macOS architectures.

## Shell block maintenance

Run:

```bash
./scripts/configure-shell.sh --dry-run
./scripts/configure-shell.sh
```

The managed block is versioned and replaced in place. An unchanged block produces no backup; a real update backs up `.zshrc`. Symlinked dotfiles are intentionally left to their source manager.

## Security and privacy review

Quarterly and after meaningful application changes:

- review Login Items & Extensions;
- review Accessibility, Full Disk Access, Screen Recording, Input Monitoring, Automation, Local Network, Camera, and Microphone grants;
- confirm FileVault, firewall, Gatekeeper, SIP, backup, and account recovery;
- remove stale browser extensions, VPN profiles, certificates, and hardware-token registrations;
- review vendor ownership, licensing, telemetry, and update channels for selected applications.

## Repository automation

The workflows provide separate evidence:

- lint and mocked failure-path tests on Linux;
- package resolution and installation on pre-provisioned Apple-silicon and Intel macOS runners;
- monthly Homebrew token and upstream freshness reports;
- quarterly editorial-review reminders;
- weekly pinned GitHub Actions update proposals.

Hosted runners are not clean retail Macs. They already contain developer tools and Homebrew. The [acceptance test](acceptance-test.md) covers the real first-boot sequence and remains a human release obligation.

## When to repeat the acceptance test

Run the complete clean or disposable Mac procedure:

- at least annually;
- after a major macOS release;
- after changing Homebrew installer verification;
- after changing architecture or shell initialization logic;
- after changing Command Line Tools assumptions;
- after a serious bootstrap or recovery defect.

Record the OS build, architecture, commit, selected options, expected warnings, failures, and corrective changes without publishing machine identifiers or credentials.
