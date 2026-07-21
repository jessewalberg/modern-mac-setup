# Bootstrap and Package Management

The bootstrap automates the narrow layer that benefits from automation: installing a reviewed set of packages through supported package-manager paths.

## Trust boundaries

The script relies on:

1. macOS and Apple's Command Line Tools;
2. HTTPS and GitHub for the official Homebrew installer;
3. Homebrew's official package metadata, bottles, formulae, and casks;
4. the upstream software represented by each selected package.

Homebrew formulae and casks are not identical trust models. Formulae in `homebrew/core` are normally installed from Homebrew-built bottles with reviewed, checksummed metadata. Casks install vendor applications and often execute vendor installers. Third-party taps are executable code and are excluded from the default and example install paths.

Read Homebrew's [installation](https://docs.brew.sh/Installation), [supply-chain](https://docs.brew.sh/Supply-Chain-Security), and [tap trust](https://docs.brew.sh/Tap-Trust) documentation before adding non-official sources.

A commented declaration is inert, but it is still a recommendation readers may copy. Example files therefore avoid disabled packages and non-official taps unless a nearby warning explains why the option is documentation-only.

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

The small baseline gives one owner to source control, GitHub operations, non-Python project runtimes, and Python projects. It does not install an editor, browser, terminal, container engine, database client, cloud CLI, or AI agent.

### Optional command-line utilities

`Brewfile.cli` adds general ergonomic and validation tools without changing the shell prompt, terminal, editor, or language versions.

```bash
./scripts/bootstrap.sh --with-cli
```

Read the tool descriptions in the README and remove anything that does not earn a place in the workflow.

### Reviewed graphical applications

Graphical applications are supplied through a separate ignored local file:

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
brew bundle check --file=Brewfile.apps --no-upgrade
brew bundle install --file=Brewfile.apps --no-upgrade
```

`Brewfile.apps.example` is a broad commented menu, not a bundle to uncomment wholesale. Prefer the built-in macOS option first, then choose one or none per responsibility. Review the [tool catalog](tool-catalog.md) before enabling a cask.

### Optional developer extras

Formulae, AI agents, cloud tools, terminal editors, shell enhancements, and role-specific utilities use another ignored local overlay:

```bash
cp Brewfile.extras.example Brewfile.local
${EDITOR:-nano} Brewfile.local
brew bundle check --file=Brewfile.local --no-upgrade
brew bundle install --file=Brewfile.local --no-upgrade
```

This layer is intentionally not a bootstrap flag. It is too broad and workflow-specific to imply a recommended combined installation. The [tool catalog](tool-catalog.md) explains use cases, overlap, permissions, data handling, and current package status.

A separate private Brewfile may hold work-specific VPN, security, communication, licensed software, and organization tools. Keep credentials and activation material outside every Brewfile.

## Upgrade behavior

The bootstrap performs `brew update` to refresh metadata, then invokes:

```bash
brew bundle install --no-upgrade
```

`--no-upgrade` reduces unexpected changes to software already present. It is not version pinning: Homebrew may still install current versions of missing packages or upgrade dependencies when necessary. Security and maintenance upgrades should be deliberate, recurring operations rather than side effects of adding one unrelated tool.

Skip the explicit metadata refresh only for a specific reason:

```bash
./scripts/bootstrap.sh --no-update
```

This flag skips the bootstrap's direct `brew update`; it should not be interpreted as a promise that every Homebrew operation is offline or unable to refresh metadata.

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

## All bootstrap options

```text
--install-homebrew   permit Homebrew installation when brew is absent
--with-cli           install Brewfile.cli
--apps FILE          install an explicitly reviewed application Brewfile
--configure-shell    append the managed zsh block
--apply-defaults     apply the narrow macOS preference script
--no-update          skip the bootstrap's explicit brew update
--dry-run            print without changing the machine
```

The `--apps FILE` option accepts any Brewfile syntax supported by Homebrew Bundle. Treat the file as executable package-manager input, not as a harmless list of names.

Continue with [Git and GitHub](03-git-and-github.md).
