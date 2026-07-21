# Contributing

Contributions should make the setup safer, smaller, clearer, more reproducible, or more useful without turning a public guide into one person's app dump.

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
- adds a third-party Homebrew tap to the default or copyable example path without a documented exceptional reason and explicit trust review;
- installs a personal application, shell framework, theme, runtime, database, AI agent, or container platform by default;
- commits tokens, private keys, recovery material, internal hosts, or private organization details;
- replaces an official supported path with a workaround copied from an old guide;
- adds a disabled, deprecated, abandoned, or architecture-incompatible package to a copyable Brewfile example.

## Adding a tool or application option

The [tool catalog](docs/tool-catalog.md) is intentionally broad, while installable defaults remain small. Inclusion in the catalog does not imply universal recommendation.

A new option should document:

1. the recurring responsibility it owns;
2. who benefits and when the built-in macOS option is sufficient;
3. overlapping alternatives already listed;
4. its current official vendor documentation and install path;
5. whether the Homebrew source is official, non-official, deprecated, or disabled;
6. Apple-silicon and minimum-macOS assumptions;
7. permissions, background items, extensions, network access, or elevated helpers;
8. source-code, document, clipboard, credential, telemetry, or cloud-data handling;
9. license or subscription considerations;
10. configuration backup, migration, and uninstall behavior.

Place the option in one of these classes:

- **Built-in** — supplied by macOS;
- **Baseline** — nearly universal for the repository's intended workflow;
- **General** — broadly useful but still optional;
- **Specialized** — valuable for a named workflow;
- **Advanced** — needs substantial configuration, permissions, or operational care;
- **Emerging** — current and useful, but comparatively young or fast-changing.

Do not use popularity alone as the selection rule. Homebrew install counts can identify candidates to research, but they do not establish quality, privacy, suitability, or long-term support.

A third-party tap may be described in prose when a credible option uses one. Do not place it in a copyable example unless the contribution explains why an official source is unavailable, cites Homebrew's tap-trust model, and makes the added executable-code trust boundary unmistakable.

## Adding a macOS preference

Prefer a supported System Settings, Finder, or application control. A setting should enter an automation script only when:

- the underlying key and type have been verified on every supported macOS version;
- the effect is narrow and understandable;
- the prior state is recorded;
- rerunning is safe;
- rollback is documented and tested;
- the value is not inherently hardware-, accessibility-, or taste-dependent.

Finder view, pointer speed, trackpad gestures, display scaling, Dock layout, and similar preferences normally belong in the [ergonomics guide](docs/macos-ergonomics.md), not in the automated baseline.

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

Also inspect every uncommented Brewfile declaration with current Homebrew metadata:

```bash
brew info NAME
brew bundle check --file=FILE --no-upgrade
```

Run state-changing scripts only on a test Mac or after reviewing the exact commands. Linux CI performs static validation and mocked dry-run/idempotence checks; it does not claim that real macOS settings, Homebrew installation, vendor installers, or privacy prompts were exercised.

## Pull requests

Keep changes reviewable and explain:

- the problem;
- why the chosen layer owns the solution;
- alternatives considered;
- the trust, privilege, data, and licensing implications;
- supported macOS and architecture assumptions;
- validation performed;
- rollback or recovery behavior.
