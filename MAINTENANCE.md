# Continuous maintenance policy

This repository is actively maintained through automated checks and recurring human review. “Maintained” does not mean every upstream release is installed blindly or that every recommendation changes automatically. It means drift is detected continuously, evidence is surfaced publicly, and recommendations are deliberately reconsidered.

## What runs automatically

| Cadence | Check | Result |
| --- | --- | --- |
| Every relevant pull request | Catalog, Brewfile, documentation, shell, and Markdown consistency | The pull request must pass before merge. |
| Every Monday | Clean macOS resolution and installation test | Foundation and CLI packages are installed, expected commands are verified, and the deep audit runs. |
| Monthly | Homebrew token and upstream freshness review | A public tracking issue is created or refreshed with the current report. |
| Weekly | GitHub Actions dependency updates | Dependabot proposes grouped, reviewable updates. |
| Quarterly | Editorial review reminder | A public checklist issue asks a human to reassess platform advice, apps, coding agents, permissions, licensing, data use, and alternatives. |
| Major macOS release | Focused compatibility review | The editorial workflow can be dispatched for a release-specific review. |
| Annually | Clean-machine acceptance test | The entire guide is exercised on a clean or disposable Mac. |

All scheduled workflows also support manual dispatch. This matters because GitHub may suspend scheduled workflows in inactive public repositories.

## What the automation verifies

- Every cataloged Homebrew formula and cask token resolves.
- Every Brewfile declaration is represented in `config/packages.yml`.
- Every package has an expected command or application bundle and an official documentation URL.
- Foundation and CLI bundles install on a current GitHub-hosted macOS runner.
- Installed formulae expose the commands documented by this repository.
- Shell scripts, Markdown, and smoke tests continue to pass.
- Upstream version differences are surfaced with Homebrew Livecheck.
- GitHub Actions dependencies receive reviewable update pull requests.

## What still requires human judgment

Automation cannot decide whether an application or coding agent remains trustworthy, well-designed, appropriately licensed, privacy-respecting, or worth recommending. The recurring editorial review covers:

- macOS support assumptions and changed System Settings paths;
- vendor ownership, licensing, telemetry, update channels, and requested permissions;
- coding-agent product names, command names, deprecations, replacement paths, subscriptions, API billing, organization policies, code use, and data retention;
- coding-agent workspace trust, sandboxing, command approval, unattended modes, network access, and MCP/plugin/hook/skill/extension boundaries;
- Apple silicon and Intel support;
- safer, simpler, native, and open-source alternatives;
- applications and agents that compete and should remain explicit choices;
- outdated advice that still passes technically;
- clean-machine usability, recovery, uninstall, and rerun behavior.

## Version policy

Normal Homebrew formulae and casks are intentionally not pinned to exact versions. Homebrew is a rolling package manager. This repository verifies that current declarations resolve and install; project-specific runtime versions belong in project configuration and lockfiles.

Security-sensitive automation dependencies are different: GitHub Actions and downloaded bootstrap sources should be pinned to immutable commits or verified checksums, then updated through reviewed pull requests.

## Public maintenance evidence

Users can inspect:

- workflow runs under the repository’s **Actions** tab;
- the continuously refreshed package-freshness issue;
- quarterly editorial-review issues and their completed checklists;
- Dependabot pull requests for automation dependencies;
- commit history for the rationale behind recommendation changes.

A green workflow is evidence that the tested installation path worked at that commit. It is not a security certification or a promise that every optional application or coding agent is appropriate for every user.

## Adding or changing a package

1. Update the appropriate Brewfile.
2. Update `config/packages.yml` with the token, type, group, expected command or app bundle, display name, and official documentation URL.
3. Update `docs/references.md` and the smallest relevant human guide; change the README only when the quick-start itself changes.
4. Run `ruby scripts/validate-catalog.rb`.
5. Run the existing lint and smoke tests.
6. On macOS, run the relevant `brew bundle check` and installation path.
7. Explain why the recommendation changed in the commit or pull request.
