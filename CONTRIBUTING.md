# Contributing

Contributions should make the setup safer, smaller, clearer, or more reproducible.

## Acceptance rules

A change should:

- solve a documented, recurring setup problem;
- cite a current primary source for platform-sensitive behavior;
- work with the Bash version shipped by supported macOS releases;
- preserve native Apple-silicon behavior and avoid accidental Rosetta use;
- remain safe to rerun;
- avoid root execution and broad permission changes;
- keep secrets and personal identity out of the repository;
- separate optional preferences and applications from the minimal foundation;
- include a rollback or recovery note for state-changing behavior;
- update documentation and validation together.

A change will not be accepted when it:

- disables SIP, Gatekeeper, quarantine, FileVault, the firewall, or automatic security improvements;
- introduces `sudo brew`, passwordless sudo, `chmod -R 777`, or unexplained recursive ownership changes;
- executes unreviewed remote code merely for convenience;
- adds a third-party Homebrew tap to the default path;
- installs a personal application, shell framework, theme, runtime, database, or container platform by default;
- commits tokens, private keys, recovery material, internal hosts, or private organization details;
- replaces an official supported path with a workaround copied from an old guide.

## Validate locally

Install the optional CLI bundle, then run:

```bash
make lint
```

At minimum:

```bash
bash -n scripts/*.sh tests/*.sh
shellcheck scripts/*.sh tests/*.sh
shfmt -d -i 2 -ci scripts tests
./tests/smoke.sh
npx --yes markdownlint-cli2@0.23.1 "**/*.md" "#.git"
```

Run state-changing scripts only on a test Mac or after reviewing the exact commands. Linux CI performs static validation and mocked dry-run/idempotence checks; it does not claim that real macOS settings, Homebrew installation, or vendor installers were exercised.

## Pull requests

Keep changes small and explain:

- the problem;
- why the chosen layer owns the solution;
- the trust and privilege implications;
- supported macOS and architecture assumptions;
- validation performed;
- rollback or recovery behavior.
