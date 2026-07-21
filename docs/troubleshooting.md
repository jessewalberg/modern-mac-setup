# Troubleshooting

Use the smallest corrective action that restores a supported state. Do not begin with recursive permission changes, disabled security controls, or a full reinstall.

## Command Line Tools are missing or unusable

Install or request the tools:

```bash
xcode-select --install
```

After the graphical installer finishes, open a new Terminal and verify functionality rather than only a path:

```bash
xcode-select -p
xcrun --find git
git --version
xcrun --find clang
clang --version
```

When `xcode-select -p` succeeds but Git or clang fails, reinstall or reselect the Command Line Tools before running Homebrew. A full Xcode installation is not required for this setup.

## The guide asks for Git before Homebrew

That is intentional. Apple Command Line Tools provide the bootstrap/default Git. Homebrew Git is an optional later layer.

Check ownership:

```bash
xcrun --find git
command -v git
git --version
```

The first path is Apple's selected Git. The second is the active shell Git and may change to Homebrew only after selecting `--with-homebrew-git`.

## `brew` exists but is not found

First determine the native architecture:

```bash
uname -m
```

Then inspect only the matching supported path:

```bash
# Apple silicon
test -x /opt/homebrew/bin/brew && /opt/homebrew/bin/brew --prefix

# Intel
test -x /usr/local/bin/brew && /usr/local/bin/brew --prefix
```

Run the managed shell updater:

```bash
./scripts/configure-shell.sh --dry-run
./scripts/configure-shell.sh
```

Do not add random Cellar directories to `PATH`.

## Bootstrap rejects the Homebrew in PATH

This is a safety check, not a cosmetic warning. Inspect:

```bash
uname -m
command -v brew
brew --prefix
ls -l /opt/homebrew/bin/brew /usr/local/bin/brew 2>/dev/null
```

For native Apple silicon, `brew --prefix` must be `/opt/homebrew`. For native Intel, it must be `/usr/local`.

Remove stale PATH initialization from the current shell or dotfile source. Do not install another Homebrew until [Migration](migration.md) has established whether the existing prefix is legacy state or an intentional isolated requirement.

## Bootstrap reports Rosetta translation

Check:

```bash
sysctl -n sysctl.proc_translated 2>/dev/null
uname -m
```

Quit the translated terminal application. In Finder, inspect **Get Info** and clear **Open using Rosetta** when present, then relaunch. Do not install Intel Homebrew merely to bypass the check.

## Homebrew installer verification fails

Stop. Do not execute the downloaded file manually.

The failure means the content no longer matches the reviewed blob in `scripts/bootstrap.sh`, or the download was incomplete or altered. Check network interception, inspect the immutable upstream commit, and update the pin only through a reviewed repository change with CI and clean-machine validation.

## Homebrew permissions errors

Confirm the architecture and prefix:

```bash
uname -m
brew --prefix
brew doctor
```

Do not run `sudo brew`, `chmod -R 777`, or recursive ownership changes against `/usr/local` or `/opt/homebrew` without understanding every file in scope. Follow Homebrew's current diagnostic output and official documentation.

## The shell block will not update

The updater refuses unsafe targets. Inspect:

```bash
ls -ld "${ZDOTDIR:-$HOME}/.zshrc"
grep -n 'modern-mac-setup' "${ZDOTDIR:-$HOME}/.zshrc"
```

A symlink should be changed in its dotfiles source. Duplicate or incomplete markers require manual repair. The script makes no change until exactly zero or one complete managed block exists.

## A cask fails or requests permissions

Read package and vendor information:

```bash
brew info --cask CASK_NAME
```

Confirm the token on [Homebrew Formulae](https://formulae.brew.sh/) and the vendor's official documentation. A cask may require a restart, conflict with another application, invoke a vendor installer, or need user-approved privacy access. Do not bypass Gatekeeper or quarantine for an unverified download.

## GitHub authentication fails

```bash
gh auth status --hostname github.com
git remote -v
gh auth login
```

For SSH, inspect `~/.ssh/config` for identity conflicts and test the documented GitHub endpoint. Never place a token directly in a remote URL.

## `mise` is installed but tools are unavailable

Open a new Terminal after shell setup, then run:

```bash
command -v mise
mise doctor
mise current
```

Inspect `.zshrc` for exactly one managed block. Multiple runtime managers may be mutating `PATH`; remove overlap only after identifying the projects that still depend on it.

## `uv` tools are not on PATH

```bash
uv tool dir --bin
uv tool list
```

Use `uv tool update-shell` only after reviewing its proposed change. Project commands should generally run through `uv run` or `uvx` and do not require globally visible executables.

## The audit exits nonzero

The audit distinguishes warnings from errors:

- warnings require human context but do not fail the command;
- errors block the selected phase and produce a nonzero exit status.

Run the correct phase explicitly:

```bash
./scripts/audit.sh --preflight
./scripts/audit.sh --post-bootstrap --deep
```

Preflight does not require Homebrew packages. Post-bootstrap does. Every checked executable is run and reported with its resolved path, so a failing tool should never appear as `[OK]`.
