# Agent instructions

This repository is written for people setting up a Mac. Keep the human path short; put implementation detail here or in the focused documents under `docs/`.

## Start here

Before changing anything:

1. Read `README.md` to understand the user journey.
2. Read `docs/design-principles.md` and `CONTRIBUTING.md` for the project rules.
3. Read the focused document for the area you are changing.
4. Inspect the scripts and tests that implement that area.
5. Run the relevant validation before committing.

Do not expand the README into a package catalog, architecture document, or maintainer manual. It is a human quick-start.

## Repository map

| Change | Read and update together |
| --- | --- |
| Default packages | `Brewfile`, `config/packages.yml`, `scripts/validate-catalog.rb`, `docs/02-bootstrap.md` |
| Optional CLI tools | `Brewfile.cli`, `config/packages.yml`, `docs/02-bootstrap.md` |
| Optional apps | `Brewfile.apps.example`, `config/packages.yml`, `docs/05-apps-and-preferences.md` |
| Optional AI editors and agents | `Brewfile.apps.example`, `config/packages.yml`, `docs/07-ai-coding-tools.md`, `docs/references.md` |
| Community and tool discovery | `docs/08-communities.md`, `docs/references.md`, and the relevant official project pages |
| Bootstrap behavior | `scripts/bootstrap.sh`, `tests/smoke.sh`, `docs/02-bootstrap.md` |
| Shell setup | `scripts/configure-shell.sh`, `tests/smoke.sh`, `docs/02-bootstrap.md` |
| macOS preferences | `scripts/macos-defaults.sh`, `tests/smoke.sh`, `docs/05-apps-and-preferences.md` |
| Audit checks | `scripts/audit.sh`, `docs/06-maintenance.md`, `docs/troubleshooting.md` |
| Git and authentication | `docs/03-git-and-github.md` |
| Language runtimes | `docs/04-runtimes.md` |
| CI and freshness automation | `.github/workflows/`, `MAINTENANCE.md` |
| Public guidance | `README.md` plus the smallest relevant document under `docs/` |

Official documentation links belong in `docs/references.md` or `config/packages.yml`, not as large catalogs in the README.

## Human-first documentation rules

- Put the shortest safe path in `README.md`.
- Put explanations, alternatives, failure modes, trust boundaries, and community maps in `docs/`.
- Put contributor and automation instructions in `CONTRIBUTING.md`, `MAINTENANCE.md`, and this file.
- Prefer progressive disclosure: command first, brief consequence second, deep link last.
- Avoid repeating the same explanation across files. Link to the source of truth.
- Do not add a tool merely to make the guide look comprehensive.
- Help readers discover active users and maintainers when that improves a decision or support path.

A README change should make the setup easier to scan. If it adds substantial background or a large table, it probably belongs elsewhere.

## Community-source rules

When adding or updating a community:

- start from an official project or organization page rather than an unverified invite posted elsewhere;
- prefer a stable community landing page over a raw Discord or Slack invite when one exists;
- label community-run or unofficial spaces clearly instead of implying vendor support;
- distinguish chat, searchable Discussions or forums, issue trackers, meetings, and announcement channels by purpose;
- verify that the community is still linked by the project and shows recent activity before recommending it;
- avoid copying private messages, member lists, or non-public workspace content;
- keep the list curated around tools and decisions in this guide rather than attempting a directory of the entire Mac ecosystem.

Community advice is discovery evidence, not authority. Platform-sensitive commands and security claims still require current primary sources.

## Non-negotiable behavior

Preserve these invariants:

- The default install remains small and broadly useful.
- Applications, coding agents, shell configuration, and macOS preferences remain explicit opt-ins.
- State-changing scripts are safe to rerun and provide a dry-run or preview where practical.
- Scripts never run Homebrew as root or recommend `sudo brew`.
- Do not disable SIP, Gatekeeper, quarantine, FileVault, the firewall, or automatic security updates.
- Do not install Rosetta automatically or mix native and translated Homebrew environments.
- Do not write Git identity, email addresses, tokens, private keys, recovery material, API keys, or cloud credentials.
- Do not grant macOS privacy permissions automatically.
- Do not sign users in to an AI provider, choose a billing plan, enable unattended agent execution, or install MCP servers, plugins, hooks, skills, or extensions.
- Do not execute mutable remote code without an explicit trust decision. The Homebrew installer uses an immutable reviewed commit.
- Project runtime versions belong in project configuration, not in a machine-wide global list.
- Platform-sensitive claims should use current primary sources.

## Package changes

When adding, removing, or renaming a package:

1. Change the appropriate Brewfile.
2. Update `config/packages.yml` with the token, type, expected command or app, name, and official docs.
3. Update only the focused human documentation that changes the decision or workflow.
4. Run the catalog validator and the normal test suite.

Keep competing applications out of the default path. Third-party Homebrew taps require a documented trust and maintenance rationale and should not be added to the default setup casually.

For AI coding tools, also verify:

- the current product and Homebrew token names;
- whether the vendor recommends a different installer or update owner;
- command, app bundle, account, subscription, and organization-policy requirements;
- workspace-trust, permission, sandbox, unattended-mode, telemetry, and data-use behavior;
- whether a formerly common tool is deprecated or has been renamed;
- that no login, credential, MCP, plugin, or autonomy configuration is automated.

## Validation

Run:

```bash
ruby scripts/validate-catalog.rb
make lint
```

For a Brewfile change on macOS, also run the relevant Homebrew checks without upgrading unrelated software:

```bash
brew bundle check --file=Brewfile --no-upgrade
brew bundle check --file=Brewfile.cli --no-upgrade
```

Run state-changing behavior only after reviewing the commands and preferably on a clean or disposable Mac. Linux CI validates syntax, formatting, Markdown, catalog consistency, and mocked behavior; it does not prove real macOS settings or vendor installers work.

## Change quality

Keep changes narrow. Explain:

- the human problem being solved;
- why this layer owns the solution;
- security, privilege, privacy, and data-use implications;
- macOS and architecture assumptions;
- validation performed;
- rollback or recovery for state-changing behavior.

When uncertain, choose the smaller change and preserve the existing safe path.
