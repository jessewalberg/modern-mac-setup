# Clean-Machine Acceptance Test

This procedure validates what hosted CI cannot: the real sequence from an updated, unconfigured Mac through Command Line Tools, Apple Git, native Homebrew, shell persistence, and post-bootstrap verification.

Use a clean or disposable Mac. Do not run destructive reset steps on a production machine merely to satisfy this checklist.

## Required test matrix

At minimum, record one native Apple-silicon run for every material bootstrap change. Test native Intel while it remains within the documented support policy and suitable hardware or virtualization is available.

Record:

- repository commit SHA;
- Mac model category without publishing serial number;
- architecture from `uname -m`;
- macOS version and build;
- clean setup or migration path;
- selected bootstrap flags;
- start and completion timestamps;
- expected warnings and unexpected failures.

Do not record recovery keys, account identifiers, tokens, private repository names, or internal hostnames.

## Phase 1: operating-system and recovery baseline

1. Complete Setup Assistant.
2. Install all offered patch and security updates, restarting and checking again.
3. Configure FileVault and store recovery material outside the Mac.
4. Configure a tested backup destination.
5. Review firewall, sharing services, screen lock, login items, and privacy permissions.
6. Confirm the terminal application runs natively.

## Phase 2: developer-tool bootstrap

Before installing Homebrew:

```bash
xcode-select --install
```

After completion:

```bash
xcode-select -p
xcrun --find git
git --version
xcrun --find clang
clang --version
```

Acceptance criteria:

- each command succeeds;
- Git and clang come from the selected Apple developer tools;
- no Homebrew path is required to clone the repository.

## Phase 3: repository preflight

```bash
git clone https://github.com/jessewalberg/modern-mac-setup.git
cd modern-mac-setup
git rev-parse HEAD
./scripts/audit.sh --preflight
```

Acceptance criteria:

- preflight exits zero on a healthy baseline;
- absent Homebrew, `gh`, `mise`, and `uv` are informational;
- architecture, FileVault, firewall, Gatekeeper, SIP, backup, Git, and clang results are understandable;
- no credential or recovery material is printed.

## Phase 4: dry run and installation

```bash
./scripts/bootstrap.sh \
  --dry-run \
  --install-homebrew \
  --configure-shell
```

Review every printed command, then apply:

```bash
./scripts/bootstrap.sh \
  --install-homebrew \
  --configure-shell
```

Acceptance criteria:

- the supported native Homebrew prefix is selected;
- the installer commit and verified blob are logged;
- the default Brewfile installs only `gh`, `mise`, and `uv`;
- `.zshrc` is backed up only when it already exists and changes;
- no credentials, identity, privacy grants, or graphical applications are configured.

## Phase 5: new-shell verification

Open a new Terminal window:

```bash
cd modern-mac-setup
command -v brew
brew --prefix
command -v git
git --version
command -v gh
command -v mise
command -v uv
./scripts/audit.sh --post-bootstrap --deep
```

Acceptance criteria:

- `brew --prefix` matches the native architecture;
- Git ownership is reported accurately;
- foundation commands execute successfully;
- the audit exits zero unless a documented environmental warning is intentionally promoted for the test;
- running `./scripts/configure-shell.sh` again makes no change or backup.

## Phase 6: optional layers

Test each selected layer separately:

```bash
./scripts/bootstrap.sh --with-cli
./scripts/bootstrap.sh --with-homebrew-git
```

For Homebrew Git, verify the active path and then verify that uninstalling or deselecting the optional layer leaves Apple Git intact.

For one representative `Brewfile.apps`, verify vendor prompts, permissions, architecture, update ownership, and removal behavior. Do not treat one representative cask as validation of every application.

## Phase 7: negative tests on a disposable environment

Where practical, confirm that the bootstrap refuses:

- Rosetta-translated execution;
- root or `sudo` execution;
- an Intel Homebrew earlier in PATH on Apple silicon;
- an Apple-silicon Homebrew earlier in PATH on Intel;
- broken Apple Git or clang;
- a mismatched Homebrew installer blob;
- malformed or duplicate shell markers;
- a symlinked `.zshrc` target.

The automated smoke suite mocks these paths on Linux, but a disposable Mac test confirms macOS-specific behavior.

## Publish evidence

Summarize the run in an issue or pull request without personal data:

```text
Commit:
macOS version/build:
Architecture:
Setup path:
Flags tested:
Expected warnings:
Unexpected failures:
Rollback/recovery tested:
Result:
```

Update the README's human-review date only after completing the relevant editorial review, not merely because CI passed.
