# Bootstrap and Package Management

The bootstrap automates only the layer that benefits from deterministic automation: architecture validation, Homebrew installation through a reviewed source, and selected package declarations.

## The bootstrap dependency chain

The sequence is intentionally explicit:

```text
macOS
  └─ Apple Command Line Tools
       ├─ Apple Git used to clone and verify the setup
       └─ Apple clang required by supported developer tooling
            └─ native Homebrew
                 ├─ GitHub CLI
                 ├─ mise
                 └─ uv
```

Homebrew Git is not required to obtain this repository. It is a separate optional layer in `Brewfile.git`.

## Install and verify Command Line Tools first

```bash
xcode-select --install
```

After installation:

```bash
xcode-select -p
xcrun --find git
git --version
xcrun --find clang
clang --version
```

The bootstrap performs the same functional checks. A selected developer directory is insufficient when Git or clang cannot execute.

## Trust boundaries

The bootstrap relies on:

1. macOS and Apple's selected Command Line Tools;
2. HTTPS and GitHub for the official Homebrew installer;
3. Homebrew's official metadata, bottles, formulae, and casks;
4. each selected upstream publisher.

Homebrew formulae and casks do not have identical trust models. Formulae in `homebrew/core` are generally installed from Homebrew-built bottles with checksummed metadata. Casks often download and run vendor-provided applications or installers. Third-party taps execute repository-controlled Ruby and are excluded from the default path.

Read Homebrew's [installation](https://docs.brew.sh/Installation), [supply-chain](https://docs.brew.sh/Supply-Chain-Security), and [tap trust](https://docs.brew.sh/Tap-Trust) documentation before adding sources.

## Why the installer is downloaded, pinned, and verified

The official one-line Homebrew command pipes a network response into Bash. This repository instead:

1. downloads `install.sh` from an immutable reviewed commit;
2. computes the file's Git blob identifier with Apple Git;
3. compares it with the reviewed blob stored in `scripts/bootstrap.sh`;
4. records a SHA-256 digest in the execution log;
5. executes the temporary file only after verification.

The commit and blob identifiers prevent an upstream branch or URL response from silently changing. They do not remove the need to trust Apple Git, GitHub, TLS, Homebrew's repository, or the human review that updates the pin.

The network operation is permitted only with:

```bash
./scripts/bootstrap.sh --install-homebrew --configure-shell
```

## Architecture and prefix enforcement

The supported native pairings are:

| Process architecture | Homebrew prefix |
| --- | --- |
| Apple silicon (`arm64`) | `/opt/homebrew` |
| Intel (`x86_64`) | `/usr/local` |

The bootstrap derives one expected executable from `uname -m`. It does not accept whichever `brew` happens to appear first in `PATH`.

It exits when:

- the terminal is running through Rosetta;
- `brew` in `PATH` reports the other architecture's prefix;
- only the other-architecture Homebrew exists;
- the executable at the supported path reports a different prefix;
- both architecture state and migration intent are ambiguous.

When both native and legacy prefixes exist, the script warns and uses only the native one. Review [Migration](migration.md) before retaining a second Homebrew.

## Package layers

### Minimal foundation

`Brewfile` installs only:

- GitHub CLI;
- `mise`;
- `uv`.

```bash
./scripts/bootstrap.sh --install-homebrew --configure-shell
```

Apple Git remains the default unless another layer changes `PATH` deliberately.

### Optional Homebrew Git

```bash
./scripts/bootstrap.sh --with-homebrew-git
command -v git
git --version
```

Use this only for a documented Git feature or version requirement. Removing `brew "git"` from `Brewfile.git` and running normal Homebrew uninstall review returns ownership to Apple Git; never delete `/usr/bin/git`.

### Optional command-line utilities

```bash
./scripts/bootstrap.sh --with-cli
```

`Brewfile.cli` contains ergonomic tools, not project runtimes or repository test dependencies.

### Reviewed applications

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
./scripts/bootstrap.sh --apps Brewfile.apps
```

Keep work-specific selections in a private Brewfile outside this public repository when they reveal internal vendors, VPNs, or licensed software.

## Upgrade behavior

The script explicitly refreshes Homebrew metadata and then installs bundles with:

```bash
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle install --no-upgrade
```

`--no-upgrade` reduces unrelated changes during installation. It is not version locking: Homebrew can install current versions of missing packages and may change dependencies when necessary.

Skip the explicit metadata refresh only for a specific, understood reason:

```bash
./scripts/bootstrap.sh --no-update
```

## Shell configuration

`--configure-shell` adds or updates one marker-bounded block in `.zshrc`. The script:

- refuses a symlinked or non-regular target;
- refuses malformed or duplicate markers;
- replaces only its own existing block;
- creates a timestamped backup before a real change;
- stages the replacement in the target directory;
- leaves an already-current block untouched.

The block checks Rosetta translation, derives the architecture-correct Homebrew path, verifies that `brew --prefix` matches it, runs `brew shellenv`, and then activates `mise` when available.

Run the shell operation independently at any time:

```bash
./scripts/configure-shell.sh --dry-run
./scripts/configure-shell.sh
```

## Dry run

```bash
./scripts/bootstrap.sh \
  --dry-run \
  --install-homebrew \
  --with-homebrew-git \
  --with-cli \
  --configure-shell
```

A dry run verifies intended control flow; it cannot prove that network downloads, vendor installers, account prompts, package conflicts, or privacy approvals will succeed.

## Complete option reference

```text
--install-homebrew      permit the reviewed Homebrew installer when brew is absent
--with-homebrew-git     install Brewfile.git
--with-cli              install Brewfile.cli
--apps FILE             install an explicitly reviewed application Brewfile
--configure-shell       add or update the managed zsh block
--apply-defaults        apply the narrow macOS preference script
--no-update             skip the explicit brew update
--dry-run               print without changing the machine
```

## Post-bootstrap verification

Open a new Terminal window, return to the repository, and run:

```bash
./scripts/audit.sh --post-bootstrap --deep
```

Continue with [Git and GitHub](03-git-and-github.md).
