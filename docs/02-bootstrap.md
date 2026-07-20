# Bootstrap and Package Management

The bootstrap automates the narrow layer that benefits from automation: installing a reviewed set of packages through supported package-manager paths.

## Trust boundaries

The script relies on:

1. macOS and Apple's Command Line Tools;
2. HTTPS and GitHub for the official Homebrew installer;
3. Homebrew's official package metadata, bottles, formulae, and casks;
4. the upstream software represented by each selected package.

Homebrew formulae and casks are not identical trust models. Formulae in `homebrew/core` are normally installed from Homebrew-built bottles with reviewed, checksummed metadata. Casks install vendor applications and often execute vendor installers. Third-party taps are executable code and are excluded from the default files.

Read Homebrew's [installation](https://docs.brew.sh/Installation), [supply-chain](https://docs.brew.sh/Supply-Chain-Security), and [tap trust](https://docs.brew.sh/Tap-Trust) documentation before adding non-official sources.

## Why the script downloads before executing

Homebrew's official one-line installation command pipes a downloaded script to Bash. This bootstrap instead downloads `install.sh` from an immutable, reviewed commit in Homebrew's official installer repository, records the downloaded file's SHA-256 value for the run log, and executes the temporary file.

The upstream commit identifier is the repository's trust pin. It prevents the command from silently changing when Homebrew's `HEAD` changes, but it does not make the installer independently trustworthy: review still rests on the official repository, GitHub, TLS, and Homebrew's release process. The pin must be deliberately refreshed when upstream installation behavior or supported macOS versions change.

The reviewed pin is visible near the top of `scripts/bootstrap.sh`. The download is permitted only with an explicit flag:

```bash
./scripts/bootstrap.sh --install-homebrew
```

## Supported prefixes and architecture

Homebrew's supported defaults are:

- `/opt/homebrew` on Apple silicon;
- `/usr/local` on Intel macOS.

The script detects either path and never hard-codes package versions inside `Cellar` directories. It exits when the current process is translated by Rosetta, because accidentally creating or using an Intel Homebrew installation on Apple silicon produces confusing duplicate toolchains.

Rosetta may still be installed manually for a specific legacy application after its need and end-of-life plan are understood. It is not a general prerequisite for a modern developer Mac.

## Command Line Tools first

Homebrew requires the Apple Command Line Tools for a supported macOS installation. The bootstrap requests them when missing and then exits. Complete Apple's installer and rerun the command rather than allowing the setup to continue against partial developer tools.

```bash
xcode-select --install
xcode-select -p
```

## Bundle layers

### Minimal foundation

`Brewfile` contains only Git, GitHub CLI, `mise`, and `uv`.

```bash
./scripts/bootstrap.sh --install-homebrew
```

### Optional command-line utilities

`Brewfile.cli` adds ergonomic and validation tools without changing the shell prompt, terminal, editor, or language versions.

```bash
./scripts/bootstrap.sh --with-cli
```

### Reviewed applications

Graphical applications are supplied through a separate local file:

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
./scripts/bootstrap.sh --apps Brewfile.apps
```

Keeping applications separate makes choices and conflicts visible. The bootstrap accepts any explicit Brewfile path, which also permits a private work-specific application list outside this public repository.

## Upgrade behavior

The script performs `brew update` to refresh metadata, then invokes:

```bash
brew bundle install --no-upgrade
```

`--no-upgrade` reduces unexpected changes to software already present. It is not version pinning: Homebrew may still install current versions of missing packages or upgrade dependencies when necessary. Security and maintenance upgrades should be deliberate, recurring operations rather than side effects of adding one unrelated tool.

Skip the metadata refresh only for a specific reason:

```bash
./scripts/bootstrap.sh --no-update
```

## Shell configuration

The optional shell script appends one clearly marked block to `.zshrc` and creates a timestamped backup first:

```bash
./scripts/bootstrap.sh --configure-shell
```

The block initializes Homebrew from either supported prefix and activates `mise`. It does not install a shell framework, prompt theme, aliases, plugins, or key bindings. Those choices should be added after the base shell is understood.

Rerunning the configuration script leaves an existing managed block untouched.

## Dry run

Preview the commands:

```bash
./scripts/bootstrap.sh --dry-run --install-homebrew --with-cli --configure-shell
```

A dry run cannot prove that network downloads, package conflicts, cask installers, or privacy prompts will succeed. It verifies the script's intended command sequence.

## All options

```text
--install-homebrew   permit Homebrew installation when brew is absent
--with-cli           install Brewfile.cli
--apps FILE          install an explicitly reviewed application Brewfile
--configure-shell    append the managed zsh block
--apply-defaults     apply the narrow macOS preference script
--no-update          skip brew update
--dry-run            print without changing the machine
```

Continue with [Git and GitHub](03-git-and-github.md).
