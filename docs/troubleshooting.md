# Troubleshooting

Use the smallest corrective action that restores a supported state. Avoid broad permission changes, recursive ownership fixes, disabling security controls, or reinstalling everything before identifying the failing layer.

## Command Line Tools installer is pending

Symptom:

```text
xcode-select: error: unable to get active developer directory
```

Action:

```bash
xcode-select --install
```

Complete the graphical installer, open a new terminal, and verify:

```bash
xcode-select -p
```

A full Xcode installation is not required for the basic Homebrew setup.

## `brew` exists but is not found

Check supported paths:

```bash
ls -l /opt/homebrew/bin/brew /usr/local/bin/brew 2>/dev/null
```

Load the matching environment for the current shell:

```bash
# Apple silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel
eval "$(/usr/local/bin/brew shellenv)"
```

The managed shell snippet detects both supported paths automatically.

Do not solve this by adding random Cellar directories to `PATH`.

## Bootstrap reports Rosetta translation

Check:

```bash
sysctl -n sysctl.proc_translated 2>/dev/null
uname -m
```

Quit the translated terminal application. In Finder, inspect the terminal application's **Get Info** panel and clear **Open using Rosetta** when present, then relaunch.

Do not install a second Intel Homebrew merely to get past the check.

## Homebrew permissions errors

First confirm Homebrew is in a supported prefix and the bootstrap was not run with sudo:

```bash
brew --prefix
brew doctor
```

Do not run `sudo brew`, `chmod -R 777`, or recursively change ownership of `/usr/local` or `/opt/homebrew` without understanding every file in scope. Follow Homebrew's current diagnostic output and official troubleshooting documentation.

## A cask fails or asks for permissions

A cask may invoke a vendor installer, require a restart, conflict with another application, or need user-approved privacy access. Read:

```bash
brew info --cask CASK_NAME
```

Confirm the token on [Homebrew Formulae](https://formulae.brew.sh/) and the vendor's official documentation. Do not bypass Gatekeeper or quarantine to make an unverified download run.

## GitHub authentication fails

Inspect:

```bash
gh auth status --hostname github.com
git remote -v
```

Reauthenticate through the browser flow:

```bash
gh auth login
```

For SSH, test the documented endpoint and inspect `~/.ssh/config` for identity conflicts. Never place a token directly in the remote URL.

## `mise` is installed but tools are unavailable

Open a new terminal after installing the shell block, then run:

```bash
command -v mise
mise doctor
mise current
```

Inspect `.zshrc` for exactly one managed block. Multiple runtime managers may be changing `PATH`; remove overlapping activation only after identifying which projects still depend on it.

## `uv` tools are not on PATH

Check:

```bash
uv tool dir --bin
uv tool list
```

Use `uv tool update-shell` only after reviewing the change it proposes. A new terminal may be required. Project commands should generally run through `uv run` or `uvx` and do not need globally installed tool executables.

## Privacy permissions appear stuck

Quit the application, review its permission category in System Settings, and reopen it. Some changes require a logout or restart. Avoid database-level TCC modifications and unsupported reset scripts unless following Apple or enterprise-management guidance for a known issue.

## The deep audit reports warnings

Run each underlying command separately. Warnings may represent:

- an optional bundle that was not selected;
- a package manager caveat;
- an unauthenticated CLI awaiting setup;
- a deliberate local customization;
- a real missing control.

Treat the audit as a structured conversation with the machine, not a pass/fail compliance certification.
