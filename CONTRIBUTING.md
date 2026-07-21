# Contributing

Contributions should make the setup safer, smaller, clearer, more testable, or more reproducible.

## Acceptance rules

A change should:

- solve a documented, recurring setup problem;
- cite a current primary source for platform-sensitive behavior;
- remain compatible with the Bash version shipped by supported macOS releases;
- preserve native Apple-silicon and Intel prefix invariants;
- remain safe to rerun and reject ambiguous state;
- avoid hidden privilege escalation and broad permission changes;
- keep secrets, identity, and machine-specific data out of the repository;
- separate optional preferences and applications from the foundation;
- include rollback or recovery notes for state-changing behavior;
- update code, tests, documentation, catalog metadata, and maintenance evidence together.

A change will not be accepted when it:

- disables SIP, Gatekeeper, quarantine, FileVault, firewall, or automatic security improvements;
- introduces `sudo brew`, passwordless sudo, `chmod -R 777`, or unexplained recursive ownership changes;
- executes mutable or unreviewed remote code for convenience;
- adds a third-party Homebrew tap to the default path;
- silently accepts the other architecture's Homebrew prefix;
- installs a personal application, shell framework, runtime, database, or container platform by default;
- commits tokens, private keys, recovery material, internal hosts, or private organization details;
- describes a pre-provisioned hosted runner as a clean-Mac bootstrap test;
- replaces a supported upstream path with a workaround copied from an old guide.

## Development tools

Install the foundation first, then use the repository-owned versions:

```bash
mise install
mise current
```

`mise.toml` pins Node.js, Ruby, ShellCheck, and `shfmt` for repository maintenance. These are not added to every Mac's global Homebrew foundation.

## Validate locally

```bash
mise run lint
```

The complete suite runs:

```bash
bash -n scripts/*.sh scripts/lib/*.sh tests/*.sh
shellcheck scripts/*.sh scripts/lib/*.sh tests/*.sh
shfmt -d -i 2 -ci scripts tests
ruby scripts/validate-catalog.rb
./tests/smoke.sh
npx --yes markdownlint-cli2@0.23.1 "**/*.md" "#.git"
```

The smoke tests cover positive and negative control flow with an isolated mock root, including:

- native Homebrew prefix selection;
- rejection of other-architecture Homebrew state;
- working Apple Git and clang requirements;
- explicit Homebrew installation consent;
- preflight and post-bootstrap semantics;
- executable failure propagation;
- shell-block update, backup, idempotence, malformed state, and symlink refusal;
- preference dry-run behavior.

Run state-changing scripts on a test Mac only after reviewing the exact commands. Linux mocks do not replace the [clean-machine acceptance test](docs/acceptance-test.md).

## Pull requests

Use the pull request template and explain:

- the problem and affected setup phase;
- why the selected layer owns the solution;
- trust, privilege, identity, architecture, and migration implications;
- supported macOS assumptions;
- automated and real-Mac validation;
- rollback or recovery behavior;
- documentation and maintenance evidence updated.

Keep changes reviewable. A broad cleanup should not hide a security or architecture fix.
