# Maintenance

A reproducible setup is a maintained process, not a one-time script.

## Weekly or after security notices

1. Install current macOS security updates and Background Security Improvements.
2. Update browsers, password managers, VPN clients, container platforms, and communication tools promptly.
3. Review any application asking for a new privileged permission after an update.
4. Push or back up important repository work.

Apple's current security-release list is maintained at [Apple security releases](https://support.apple.com/en-us/100100).

## Monthly package review

Inspect before upgrading:

```bash
brew update
brew outdated
mise outdated
```

Apply reviewed Homebrew upgrades:

```bash
brew upgrade
brew cleanup
```

`brew cleanup` removes old package versions and cache material; it does not make the machine match a Brewfile. Do not run `brew bundle cleanup --force` casually because it can remove software not represented in the selected bundle.

Verify declarations without forcing upgrades:

```bash
brew bundle check --file=Brewfile --no-upgrade
brew bundle check --file=Brewfile.cli --no-upgrade
```

For a reviewed apps file:

```bash
brew bundle check --file=Brewfile.apps --no-upgrade
```

## Audit privileged state

Review these System Settings periodically:

- Login Items & Extensions;
- Accessibility;
- Full Disk Access;
- Screen & System Audio Recording;
- Input Monitoring;
- Local Network;
- Files & Folders;
- VPN & Filters;
- Sharing;
- Firewall options.

Remove permissions and background items for software no longer used, then uninstall the software through its documented removal path.

## Run diagnostics

```bash
./scripts/audit.sh --deep
```

Also review:

```bash
brew doctor
mise doctor
gh auth status --hostname github.com
```

A clean `brew doctor` is useful but not a security attestation. Some warnings are expected on intentionally customized systems.

## Review GitHub access

Periodically review:

- SSH keys;
- personal access tokens;
- authorized OAuth and GitHub Apps;
- organization access;
- signed-in devices and security keys;
- recovery codes and multi-factor authentication methods.

Revoke credentials that are unknown, unused, or tied to retired devices. Rotation is most valuable when a key is exposed, weak, shared, or outside policy; arbitrary rotation without inventory can create outages.

## Test recovery

A backup that has never been restored is an assumption. On a recurring schedule:

1. confirm the backup destination is receiving new snapshots;
2. restore representative files to a separate location;
3. verify source repositories and unpushed work;
4. confirm password-manager and account recovery from another trusted device;
5. review FileVault recovery handling;
6. document anything that exists only on the Mac.

## Keep this repository current

When a command or package changes:

1. prefer an official primary source;
2. update the relevant documentation and script together;
3. preserve compatibility with the system Bash shipped by supported macOS versions;
4. run the linters;
5. avoid adding a dependency only to support the setup script;
6. record the review date when a platform assumption materially changes.
