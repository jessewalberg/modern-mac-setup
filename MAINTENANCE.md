# Continuous Maintenance Policy

This repository is maintained through automated checks and recurring human review. “Maintained” means drift is detected, evidence is public, and recommendations are deliberately reconsidered. It does not mean every upstream release is installed automatically.

## Evidence classes

| Evidence | Environment | What it proves | What it does not prove |
| --- | --- | --- | --- |
| Static and mocked validation | Linux runner | Shell syntax, formatting, catalog consistency, documentation lint, and controlled failure paths | Real macOS commands, privacy prompts, vendor installers, or hardware behavior |
| Hosted macOS package validation | Pre-provisioned Apple-silicon and Intel GitHub runners | Native prefix assumptions, Brewfile resolution/install, command execution, and audit compatibility | First-boot Command Line Tools installation or a clean retail Mac |
| Clean-machine acceptance | Clean or disposable Mac | End-to-end documented sequence, shell persistence, prompts, reruns, and recovery | Every optional vendor application or future upstream release |

The documentation must use these names accurately.

## Cadence

| Cadence | Check | Result |
| --- | --- | --- |
| Every relevant pull request | Lint, catalog, mocked regressions, and hosted macOS package tests | Required evidence before merge |
| Every Monday | Hosted Apple-silicon and Intel package validation | Current foundation and CLI declarations are exercised |
| Monthly | Homebrew token and upstream freshness review | Public tracking issue is created or refreshed |
| Weekly | GitHub Actions dependency review | Dependabot proposes grouped, reviewable updates |
| Quarterly | Editorial review | Human checklist covers platform instructions, apps, permissions, licensing, and alternatives |
| Major macOS or bootstrap change | Focused compatibility review | Acceptance scope is selected explicitly |
| At least annually | Clean-machine acceptance test | End-to-end evidence is recorded against a commit |

Scheduled workflows also support manual dispatch because inactive public repositories can have schedules suspended.

## Automated guarantees

Automation verifies that:

- every Homebrew declaration has catalog metadata and official documentation;
- every cataloged declaration appears in the correct Brewfile layer;
- the README documents each selected package category;
- foundation and CLI formulae resolve and install on current hosted Apple-silicon and Intel runners;
- expected commands execute rather than merely exist;
- shell scripts pass syntax, ShellCheck, formatting, and mocked regression tests;
- the architecture-correct Homebrew prefix is used;
- GitHub Actions dependencies are pinned and receive reviewable update proposals;
- upstream package differences are surfaced for review.

## Human review obligations

Automation cannot decide whether an application remains trustworthy, useful, appropriately licensed, privacy-respecting, or worth its permissions. Editorial review covers:

- supported macOS versions and changed System Settings paths;
- Command Line Tools and Apple Git assumptions;
- Homebrew installer commit/blob review and supported prefixes;
- vendor ownership, license, telemetry, update channel, and requested permissions;
- Apple-silicon and Intel support;
- safer, simpler, native, or open-source alternatives;
- competing applications that must remain explicit choices;
- recovery, uninstall, rerun, and migration behavior;
- advice that passes technically but is no longer good guidance.

## Version policy

Homebrew formulae and casks are not pinned to exact versions because Homebrew is a rolling package manager. This repository verifies current resolution and installation. Project runtimes belong in project configuration and lockfiles.

Repository development tools are pinned in `mise.toml`. Downloaded bootstrap sources and GitHub Actions are pinned to immutable content or commit identifiers and updated only through reviewed changes.

## Public evidence

Users can inspect:

- workflow runs under **Actions**;
- monthly package-freshness issues;
- quarterly editorial-review issues;
- Dependabot pull requests;
- clean-machine acceptance records;
- commit and pull request rationale.

A green badge is evidence for one tested environment and commit. It is not a security certification.

## Package changes

1. Update the correct Brewfile.
2. Update `config/packages.yml`.
3. Update the README and relevant guide.
4. Run `mise run lint`.
5. Exercise the relevant hosted macOS matrix.
6. Run the clean-machine test when architecture, bootstrap, shell, or installer behavior changes.
7. Document rationale and rollback in the pull request.
