# Agent instructions

This repository is written for people setting up a Mac. Keep the public path short and put implementation detail here or in `docs/REFERENCE.md`.

## Start here

Before changing anything:

1. Read `README.md` for the human journey.
2. Read `docs/REFERENCE.md` for design and operational context.
3. Inspect the scripts, Brewfiles, catalog, workflows, and tests involved.
4. Run the relevant validation before committing.

Do not create another Markdown guide for a narrow topic. The documentation model is intentionally limited to:

- `README.md` for the human setup path;
- `docs/REFERENCE.md` for deeper human reference;
- `AGENTS.md` for maintainers and coding agents;
- `CONTRIBUTING.md` and `SECURITY.md` for GitHub-standard policies.

Add a new document only when it has a durable audience and cannot fit one of those files without making navigation worse.

## Repository map

| Change | Read and update together |
| --- | --- |
| Foundation packages | `Brewfile`, `config/packages.yml`, `scripts/validate-catalog.rb` |
| Optional CLI tools | `Brewfile.cli`, `config/packages.yml` |
| Optional apps or agents | `Brewfile.apps.example`, `config/packages.yml` |
| Bootstrap or shell behavior | `scripts/bootstrap.sh`, `scripts/configure-shell.sh`, `tests/smoke.sh` |
| macOS preferences | `scripts/macos-defaults.sh`, `tests/smoke.sh` |
| Audit behavior | `scripts/audit.sh`, tests, and troubleshooting text in `docs/REFERENCE.md` |
| Human workflow | `README.md` and, only when needed, `docs/REFERENCE.md` |
| CI and freshness | `.github/workflows/`, this file, and relevant scripts |

The machine-readable package catalog owns package metadata and official documentation URLs. Do not duplicate a full package link catalog in Markdown.

## Human-first documentation rules

- Put the shortest safe path in `README.md`.
- Put explanations, alternatives, failure modes, recovery notes, and trust boundaries in `docs/REFERENCE.md`.
- Prefer progressive disclosure: command first, brief consequence second, deeper reference last.
- Avoid repeating the same explanation in multiple files.
- Do not add a tool or community merely to make the repository look comprehensive.
- Remove stale material instead of preserving it for history; Git already provides history.

A README change should make setup easier to scan. If it adds a large table, catalog, or maintainer process, move or compress it.

## Non-negotiable behavior

Preserve these invariants:

- The default install remains small and broadly useful.
- Applications, agents, shell configuration, and macOS preferences remain explicit opt-ins.
- State-changing scripts are safe to rerun and provide a dry-run or preview where practical.
- Scripts never run Homebrew as root or recommend `sudo brew`.
- Do not disable SIP, Gatekeeper, quarantine, FileVault, the firewall, or automatic security updates.
- Do not install Rosetta automatically or mix native and translated Homebrew environments.
- Do not write Git identity, email addresses, tokens, private keys, recovery material, API keys, or cloud credentials.
- Do not grant macOS privacy permissions automatically.
- Do not sign users in to providers, choose billing plans, enable unattended agents, or install MCP servers, plugins, hooks, skills, or extensions.
- Do not execute mutable remote code without an explicit trust decision.
- Project runtime versions belong in project configuration, not in a machine-wide list.
- Platform-sensitive claims should use current primary sources.

## Package changes

When adding, removing, or renaming a package:

1. Change the appropriate Brewfile.
2. Update `config/packages.yml` with token, type, group, expected command or app, display name, and official docs URL.
3. Change the README only when the human workflow changes; otherwise update the reference only when a decision or warning changes.
4. Run the catalog validator and normal test suite.

Keep competing applications out of the default path. Third-party taps require a documented trust and maintenance rationale and should not enter the default setup casually.

For coding agents, also verify current product and command names, installation owner, account requirements, data use, workspace trust, sandboxing, approval modes, unattended behavior, and deprecations.

For community links, start from an official project page, prefer stable landing pages over raw invite URLs, label unofficial spaces, and use community advice only as discovery evidence.

## Validation

Run:

```bash
ruby scripts/validate-catalog.rb
make lint
```

For Brewfile changes on macOS, also run:

```bash
brew bundle check --file=Brewfile --no-upgrade
brew bundle check --file=Brewfile.cli --no-upgrade
```

Run state-changing behavior only after reviewing commands and preferably on a clean or disposable Mac. Linux CI validates syntax, formatting, Markdown, catalog consistency, and mocked behavior; it does not prove real macOS settings or vendor installers.

## Maintenance policy

Automation should verify package declarations, current Homebrew resolution, expected commands, shell and Markdown quality, smoke tests, freshness, and pinned workflow dependencies.

Human review is still required after major macOS changes and for application ownership, licensing, permissions, privacy, agent behavior, community links, and outdated advice that can still pass technically.

Normal Homebrew packages are not pinned to historical versions. Security-sensitive workflow actions and downloaded bootstrap sources should use immutable reviewed commits or verified checksums.

A green workflow is evidence for the tested path at that commit, not a security certification.

## Change quality

Keep changes narrow. Explain the human problem, why the chosen layer owns it, security and privacy implications, platform assumptions, validation, and rollback or recovery for state-changing behavior.

When uncertain, choose the smaller change and preserve the existing safe path.
